<?php

namespace Database\Seeders;

use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::query()->updateOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'password' => 'password',
                'email_verified_at' => now(),
            ],
        );

        $mahasiswa = User::query()->updateOrCreate(
            ['email' => 'mahasiswa@jti.polinema.ac.id'],
            [
                'name' => 'Mahasiswa JTI',
                'password' => 'password',
                'email_verified_at' => now(),
            ],
        );

        AppNotification::query()->firstOrCreate(
            [
                'user_id' => $mahasiswa->id,
                'title' => 'Pengumuman awal semester',
            ],
            [
                'type' => 'list',
                'body' => 'Cek jadwal UTS di portal akademik. Ketuk item ini supaya hilang dari kotak masuk.',
                'route' => '/pengumuman/1',
            ],
        );
    }
}
