import SwiftUI

/// Çentik ana cam ada arayüzü.
/// Bkz. docs/06-tasarim-dili-ve-arayuz-sistemi.md
struct NotchContainerView: View {
    @ObservedObject var viewModel: NotchViewModel
    @ObservedObject var screenManager: ScreenManager
    
    var body: some View {
        ZStack(alignment: .top) {
            // Arka Cam Gövde (Liquid Frosted Glass)
            RoundedRectangle(cornerRadius: viewModel.isExpanded ? 28 : (screenManager.hasNotch ? 14 : 20), style: .continuous)
                .fill(Color(red: 7/255, green: 9/255, blue: 14/255).opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: viewModel.isExpanded ? 28 : (screenManager.hasNotch ? 14 : 20), style: .continuous)
                        .stroke(Color(red: 30/255, green: 41/255, blue: 59/255), lineWidth: 1.5)
                )
            
            // İçerik Katmanı
            if viewModel.isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
            } else {
                collapsedContent
                    .transition(.opacity)
            }
        }
        .frame(
            width: viewModel.isExpanded ? viewModel.expandedWidth : (screenManager.hasNotch ? max(screenManager.notchWidth, 200) : 180),
            height: viewModel.isExpanded ? viewModel.expandedHeight : (screenManager.hasNotch ? screenManager.notchHeight : 34)
        )
        .onHover { hovering in
            viewModel.onHoverChanged(hovering)
        }
    }
    
    // MARK: - Kapalı Durum Görünümü
    private var collapsedContent: some View {
        HStack(spacing: 8) {
            if !screenManager.hasNotch {
                // Hap Modu: Çentiksiz Mac'lerde merkezde hafif parıltı
                Circle()
                    .fill(Color(red: 0/255, green: 102/255, blue: 255/255))
                    .frame(width: 6, height: 6)
                
                Text("Çentik")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            } else {
                Spacer()
                // Çentikli Mac: Çentik altında bekleme çizgisi
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 3)
                    .padding(.bottom, 2)
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 12)
    }
    
    // MARK: - Genişletilmiş Ada Paneli
    private var expandedContent: some View {
        VStack(spacing: 12) {
            // Üst Başlık & Durum
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0/255, green: 102/255, blue: 255/255))
                        .frame(width: 8, height: 8)
                    Text("ÇENTİK")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 56/255, green: 189/255, blue: 248/255))
                }
                
                Spacer()
                
                Text("Esc ile kapat")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 148/255, green: 163/255, blue: 184/255))
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            Divider()
                .background(Color(red: 30/255, green: 41/255, blue: 59/255))
                .padding(.horizontal, 12)
            
            // Faz 1 Modül İskeletleri
            HStack(spacing: 12) {
                // 1. Dosya Rafı Alanı
                VStack(spacing: 6) {
                    Image(systemName: "tray.and.arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0/255, green: 102/255, blue: 255/255))
                    Text("Dosya Bırak")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                    Text("Bırak, dursun")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 17/255, green: 21/255, blue: 34/255))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 30/255, green: 41/255, blue: 59/255), lineWidth: 1)
                )
                
                // 2. Medya / Pano Alanı
                VStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0/255, green: 180/255, blue: 255/255))
                    Text("Now Playing")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                    Text("Müzik çalmıyor")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 17/255, green: 21/255, blue: 34/255))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 30/255, green: 41/255, blue: 59/255), lineWidth: 1)
                )
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
    }
}
