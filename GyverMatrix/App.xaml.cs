﻿using Xamarin.Essentials;
using Xamarin.Forms;

namespace GyverMatrix {
    public partial class App {
        public App() {
            InitializeComponent();
            MainPage = new AppShell();
        }

        private async void App_OnPageAppearing(object sender, Page e) {
            if (await SecureStorage.GetAsync("Theme") != null)
                return;
            await SecureStorage.SetAsync("Theme", "Dark");
            UserAppTheme = OSAppTheme.Dark;
        }
    }
}