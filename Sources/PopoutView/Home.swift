//
//  Home.swift
//  PopoutView
//
//  Created by ChuanqingYang on 2025/5/7.
//

import SwiftUI

struct Home: View {
    @Namespace var animation
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            case1()
            
            case2()
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func case1() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                
                PopoutView { isExpanded in
                    HStack(spacing: 10) {
                        ZStack {
                            if !isExpanded {
                                Image(systemName: "number")
                                    .fontWeight(.semibold)
                                    .matchedGeometryEffect(id: "#", in: animation)
                            }
                        }
                        .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 0) {
                                if isExpanded {
                                    Image(systemName: "number")
                                        .scaleEffect(0.8)
                                        .matchedGeometryEffect(id: "#", in: animation)
                                }
                                Text("general")
                            }
                            .fontWeight(.semibold)
                            
                            Text("36 Members - 4 Online")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .offset(x: isExpanded ? -30 : 0)
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                } content: { isExpanded in
                    Text("Content")
                }
                
                Image(systemName: "globe")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func case2() -> some View {
        PopoutView { isExpanded in
            HStack {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .contentShape(.rect)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity, alignment: isExpanded ? .trailing : .leading)
            .background {
                Color.indigo
            }
        } content: { isExpanded in
            Text("Content")
        }

    }
}

#Preview {
    Home()
}
