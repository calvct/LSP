//
//  Supabase.swift
//  LSP
//
//  Created by Calvin Christian Tjong on 17/12/25.
//


import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://yxlpyycjwwkudkujxlrb.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4bHB5eWNqd3drdWRrdWp4bHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5NzE5NDcsImV4cCI6MjA4MTU0Nzk0N30.lyvcthLqCNlwfFwiCZYYtRwdvVoetKRGiuqCt1s_xDE",
  options: SupabaseClientOptions(
    db: .init(schema: "public"),
    auth: .init(
        emitLocalSessionAsInitialSession: true
        )
    )
)
        
