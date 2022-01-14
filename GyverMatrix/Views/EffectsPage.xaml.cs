﻿using GyverMatrix.Helpers;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xamarin.Essentials;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace GyverMatrix.Views {
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class EffectsPage {
        public EffectsPage() =>
            InitializeComponent();

        private async Task SetBrightnesstAsync() {
            await UdpHelper.Send("$4 0 " + (int)BrightnessSlider.Value + ";");
            await SecureStorage.SetAsync("BR", ((int)BrightnessSlider.Value).ToString());
        }
        private async Task SetSpeedAsync() {
            await UdpHelper.Send("$15 " + (int)SpeedSlider.Value + " 0;");
        }
        private async void EffectSwitch_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e) {
            int num = Effects.SelectedIndex;

            string Mode = HourSwitch.IsToggled ? "1" : "0";

            if (Mode != await SecureStorage.GetAsync("ESW" + num)) {
                if (Mode == "0") {
                    await UdpHelper.Send("$8 2 " + num + " 0;");
                    await SecureStorage.SetAsync("ESW" + num, Mode);
                } else if (Mode == "1") {
                    await UdpHelper.Send("$8 2 " + num + " 1;");
                    await SecureStorage.SetAsync("ESW" + num, Mode);
                }
            }
        }
        private async void HourSwitch_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e) {
            int num = Effects.SelectedIndex;

            string Mode = HourSwitch.IsToggled ? "1" : "0";

            if (Mode != await SecureStorage.GetAsync("HSW" + num)) {
                if (Mode == "0") {
                    //await UdpHelper.Send("$19 0 1;"); //добавлю позже
                    await SecureStorage.SetAsync("HSW" + num, Mode);
                } else if (Mode == "1") {
                    //await UdpHelper.Send("$16 0;"); //добавлю позже
                    await SecureStorage.SetAsync("HSW" + num, Mode);
                }
            }
        }
        private async void BrightnessSlider_ValueChanged(object sender, ValueChangedEventArgs e) {
            BrightnessText.Text = ((int)((Slider)sender).Value).ToString();
            await SetBrightnesstAsync();
        }
        private async void SpeedSlider_ValueChanged(object sender, ValueChangedEventArgs e) {
            SpeedText.Text = ((int)((Slider)sender).Value).ToString();
            await SetSpeedAsync();
        }

        private async void ContentPage_Appearing(object sender, System.EventArgs e) {

            string EffectsListText = await SecureStorage.GetAsync("Effects");
            string[] EffectsList = EffectsListText.Split(',');
            foreach (var t in EffectsList) {
                Effects.Items.Add(t);
            }
        }



        private async void Effects_SelectedIndexChanged(object sender, EventArgs e) {
            int num = Effects.SelectedIndex;

            if (num > -1) {
                await UdpHelper.Send("$8 0 " + num + ";");
                int a;
                string message = "";
                do {
                    string ack = await ParseHelper.Effects(await UdpHelper.Receive());

                    if (ack == "ack") {
                        a = 0;
                    } else { a = 1; message = ack; Console.WriteLine(ack); }
                }
                while (a == 0);
                //string debug = await ParseHelper.Effects(await UdpHelper.Receive()); // ДИМА, НЕ УДАЛЯЙ!!!! без него он возвращает ack

                //string message = await ParseHelper.Effects(num);
                Console.WriteLine(message);
                if (message != "") {
                    Console.WriteLine("я добрался до сюда");
                    string[] message1 = message.Split('|');

                    for (int i = 0; i < message1.Length; i++) {
                        Console.WriteLine(message1[i]);
                    }

                    BrightnessSlider.Value = int.Parse(message1[2].Split(':')[1]);
                    if (message1[3].Split(':')[1] != "X") {
                        SpeedSlider.Value = int.Parse(message1[3].Split(':')[1]);
                    }

                    int x = 0;
                    if (message1[6].Split(':')[1] != "X") {
                        x = int.Parse(message1[6].Split(':')[1]);
                    }
                    int y = int.Parse(message1[7].Split(':')[1]);

                    await SecureStorage.SetAsync("HSW" + num, message1[6].Split(':')[1]);
                    await SecureStorage.SetAsync("ESW" + num, message1[7].Split(':')[1]);

                    HourSwitch.IsToggled = x == 1;

                    EffectSwitch.IsToggled = y == 1;


                }
            }


            Console.WriteLine(Effects.SelectedIndex);
        }
    }
}