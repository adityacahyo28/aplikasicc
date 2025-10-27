package com.example.applicationgua

import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView
import com.example.applicationgua.R.*
import com.example.applicationgua.R.id.*

class MainActivity : AppCompatActivity() {
    @SuppressLint("MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(layout.activity_main) // sesuai dengan nama file layout kamu

        // Hubungkan komponen dari XML
        val textView = findViewById<TextView>(textView2)
        val imageView = findViewById<ImageView>(imageView)

        // Ubah teks secara dinamis (opsional)
        textView.text = "Selamat Datang di Aplikasi Saya"
    }
}