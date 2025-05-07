// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct PopoutView<Header: View, Content: View>: View {
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: (Bool) -> Content
    
    // view properties
    @State private var sourceReact: CGRect = .zero
    @State private var showFullScreenCover: Bool = false
    @State private var animateView: Bool = false
    @State private var haptics: Bool = false
    public var body: some View {
        header(animateView)
            .background(solidBackground(.gray, opacity: 0.1))
            .clipShape(.rect(cornerRadius: 10))
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: { newValue in
                print("rect:\(newValue)")
                sourceReact = newValue
            }
            .opacity(showFullScreenCover ? 1 : 1)
            .contentShape(.rect)
            .onTapGesture {
                haptics.toggle()
                toggleFullScreenCover()
            }
            .fullScreenCover(isPresented: $showFullScreenCover) {
                PopoutOverlay(
                    animateView: $animateView,
                    sourceRect: $sourceReact,
                    header: header,
                    content: content
                ) {
                    withAnimation(.easeInOut(duration: 0.25), completionCriteria: .removed) {
                        animateView = false
                    } completion: {
                        toggleFullScreenCover()
                    }

                }
            }
            .sensoryFeedback(.impact, trigger: haptics)

    }
    
    private func toggleFullScreenCover() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            showFullScreenCover.toggle()
        }
    }
}

// custom overlay view
public struct PopoutOverlay<Header: View, Content: View>: View {
    @Binding var animateView: Bool
    @Binding var sourceRect: CGRect
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: (Bool) -> Content
    
    var dismissView: () -> Void
    
    // view properties
    @State private var edgeInsets: EdgeInsets = .init()
    @State private var scale: CGFloat = 1
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                if animateView {
                    Button(action: dismissView) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                            .contentShape(.rect)
                    }
                }
                header(animateView)
            }
            
            if animateView {
                content(animateView)
                    .transition(.blurReplace)
            }
        }
        .frame(maxWidth: animateView ? .infinity : nil)
        .padding(animateView ? 15 : 0)
        .background {
            ZStack {
                solidBackground(.gray, opacity: 0.1)
                    .opacity(!animateView ? 1 : 0)
                
                Rectangle()
                    .fill(.background)
                    .opacity(animateView ? 1 : 0)
            }
        }
        .clipShape(.rect(cornerRadius: animateView ? 20 : 10))
        .scaleEffect(scale, anchor: .top)
        .frame(
            width: animateView ? nil : sourceRect.width,
            height: animateView ? nil : sourceRect.height
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .offset(
            x: animateView ? 0 : sourceRect.minX,
            y: animateView ? sourceRect.origin.y : sourceRect.minY
        )
        .padding(animateView ? 15 : 0)
        .padding(.top, animateView ? edgeInsets.top : 0)
        .ignoresSafeArea()
        .presentationBackground {
            GeometryReader {
                let size = $0.size
                Rectangle()
                    .fill(.black.opacity(animateView ? 0.5 : 0))
                    .onTapGesture {
                        dismissView()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                let height = value.translation.height
                                let scale = height / size.height
                                let applyingRatio: CGFloat = 0.1
                                self.scale = 1 + (scale * applyingRatio)
                            })
                            .onEnded({ value in
                                let velocityHeight = value.velocity.height / 5
                                let height = value.translation.height + velocityHeight
                                let scale = height / size.height
                                let applyingRatio: CGFloat = 0.1
                                
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    self.scale = 1
                                }
                                
                                if -scale > 0.5 {
                                    dismissView()
                                }
                            })
                    )
            }
        }
        .onGeometryChange(for: EdgeInsets.self) {
            $0.safeAreaInsets
        } action: { newValue in
            guard !animateView else { return }
            edgeInsets = newValue
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.25)) {
                    animateView = true
                }
            }
        }

        
    }
}

extension View {
    func solidBackground(_ color: Color, opacity: CGFloat) -> some View {
        Rectangle()
            .fill(.background)
            .overlay {
                Rectangle()
                    .fill(color.opacity(opacity))
            }
    }
}
