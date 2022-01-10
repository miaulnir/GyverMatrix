﻿using System;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace GyverMatrix.Helpers {
    internal class UdpHelper : IDisposable {
        private readonly UdpClient _udpClient = new UdpClient();
        public UdpHelper(string ipAdress, int port) =>
            _udpClient.Connect(ipAdress, port);

        public async Task Send(string message) {
            var data = Encoding.UTF8.GetBytes(message);
            await _udpClient.SendAsync(data, data.Length);
        }

        public async Task<string> Receive() {
            var data = await _udpClient.ReceiveAsync();
            return Encoding.UTF8.GetString(data.Buffer);
        }
        //IPEndPoint ip = null;

        //byte[] data = client.Receive(ref ip);
        //string message = Encoding.UTF8.GetString(data);
        //    return message;
        public void Dispose() {
            _udpClient.Close();
            _udpClient?.Dispose();
            GC.SuppressFinalize(true);
        }
    }
}