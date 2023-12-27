import SwiftUI

struct RootView<Content: View>: View {
    @ViewBuilder var content: Content
    @State var overlayWindow: UIWindow?
    
    var body: some View {
        content.onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               overlayWindow == nil {
                let window = PassThroughWindow(windowScene: windowScene)
                window.backgroundColor = .clear
                let rootViewController = UIHostingController(rootView: ToastGroup())
                if #available(iOS 15.0, *) {
                    rootViewController.view.frame = windowScene.keyWindow?.frame ?? .zero
                } else {
                    rootViewController.view.frame = windowScene.windows.first?.frame ?? .zero
                }
                rootViewController.view.backgroundColor = .clear
                window.rootViewController = rootViewController
                window.isHidden = false
                window.isUserInteractionEnabled = true
                window.tag = 1009
                overlayWindow = window
            }
        }
    }
}

fileprivate class PassThroughWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}

public class Toast: ObservableObject {
    public static var shared: Toast = Toast()
    @Published var toasts: [ToastItem] = []
    
    public func present(title: String, symbol: String?,
                 tint: Color = .primary,
                 isUserInteractionEnabled: Bool = true,
                 isDismissible: Bool = false,
                 isAutoDismissed: Bool = true,
                 timing: ToastTime = .long) {
        withAnimation(.snappy) {
            if isAutoDismissed {
                toasts.append(.init(title: title,
                                    symbol: symbol,
                                    tint: tint,
                                    isUserInteractionEnabled: isUserInteractionEnabled,
                                    isDismissible: false,
                                    timing: timing))
            } else {
                if toasts.isEmpty {
                    toasts.append(.init(title: title,
                                        symbol: symbol,
                                        tint: tint,
                                        isUserInteractionEnabled: isUserInteractionEnabled,
                                        isDismissible: isDismissible,
                                        timing: timing))
                }
            }
        }
    }
}

public struct ToastItem: Identifiable {
    public let id: UUID = .init()
    public var title: String
    public var symbol: String?
    public var tint: Color
    public var isUserInteractionEnabled: Bool
    public var isDismissible: Bool
    public var timing: ToastTime = .medium
}

public enum ToastTime: CGFloat {
    case short = 1.0
    case medium = 2.0
    case long = 3.0
}

fileprivate struct ToastGroup: View {
    @ObservedObject var model = Toast.shared
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            ZStack {
                ForEach(model.toasts) { toast in
                    
                    SwiftUIToastView(size: size, item: toast)
                        .scaleEffect(scale(toast))
                        .offset(y: offsetY(toast))
                }
                .padding(.bottom, safeArea.top == .zero ? 15 : 10)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    func offsetY(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        return (totalCount - index) >= 2 ? -20 : ((totalCount - index) * -10)
    }
    
    func scale(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        return 1.0 - ((totalCount - index) >= 2 ? 0.2 : ((totalCount - index) * 0.1))
    }
}

struct SwiftUIToastView: View {
    var size: CGSize
    var item: ToastItem
    
    @State
    private var delayTask: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 12) {
            if let symbol = item.symbol {
                Image(systemName: symbol)
                    .font(.title)
                    .foregroundColor(Color(UIColor.systemBackground))
            }
            Text(item.title)
                .lineLimit(3)
                .foregroundColor(Color(UIColor.systemBackground))
            if item.isDismissible {
                Button {
                    removeToast()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .font(.largeTitle)
                }
                
            }
            
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color(UIColor.label))
        .cornerRadius(10)
        .shadow(radius: 10)
        .gesture( DragGesture (minimumDistance: 0)
            .onEnded ({ value in
                guard item.isUserInteractionEnabled else { return }
                let endY = value.translation.height
                let velocityY = value.velocity.height
                if (endY + velocityY) > 100  {
                    removeToast()
                }
            }))
        .onAppear {
            guard delayTask == nil else { return }
            delayTask = .init(block: {
                if !item.isDismissible {
                    removeToast()
                }
            })
            if let delayTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + item.timing.rawValue, execute: delayTask)
            }
        }
        .frame(maxWidth: size.width * 0.95)
        .transition(.offset(y: 150))
    }
    
    func removeToast() {
        if let delayTask {
            delayTask.cancel()
        }
        print("\(909)")
        withAnimation(.snappy) {
            Toast.shared.toasts.removeAll(where: { $0.id == item.id } )
        }
    }
    
}

