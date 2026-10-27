<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = AppNotification::query()
            ->where('user_id', $request->user()->id)
            ->where('type', 'list')
            ->whereNull('read_at')
            ->latest()
            ->get();

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', 'in:list,icon,sound'],
            'title' => ['required', 'string', 'max:255'],
            'body' => ['nullable', 'string'],
            'route' => ['nullable', 'string', 'max:255'],
        ]);

        $item = AppNotification::query()->create([
            ...$data,
            'user_id' => $request->user()->id,
        ]);

        return response()->json(['data' => $item], 201);
    }

    public function markRead(Request $request, AppNotification $notification): JsonResponse
    {
        abort_unless($notification->user_id === $request->user()->id, 403);

        $notification->update(['read_at' => now()]);

        return response()->json(['data' => $notification]);
    }
}
