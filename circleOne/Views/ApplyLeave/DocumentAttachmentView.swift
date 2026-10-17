import SwiftUI

public struct DocumentAttachmentView: View {
    @Binding var attachmentName: String?
    public let isRequired: Bool
    @State private var showingDocSelector: Bool = false
    
    public init(attachmentName: Binding<String?>, isRequired: Bool = false) {
        self._attachmentName = attachmentName
        self.isRequired = isRequired
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Supporting Document")
                    .font(.system(size: 14, weight: .semibold))
                
                if isRequired {
                    Text("• Required")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.red)
                } else {
                    Text("• Optional")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let name = attachmentName, !name.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                        
                        Text("PDF Document • 420 KB")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        attachmentName = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            } else {
                Button {
                    showingDocSelector = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "paperclip")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Text("Attach Medical Slip / Document")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(14)
                    .foregroundColor(.blue)
                    .background(Color.circleCardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isRequired ? Color.red.opacity(0.3) : Color.blue.opacity(0.2),
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                            )
                    )
                }
                .confirmationDialog("Choose Attachment", isPresented: $showingDocSelector) {
                    Button("Upload Medical Certificate (MC.pdf)") {
                        attachmentName = "Medical_Certificate_Oct2026.pdf"
                    }
                    Button("Take Photo of Document") {
                        attachmentName = "Photo_Document_Scan.jpg"
                    }
                    Button("Choose from Files / Photos") {
                        attachmentName = "Travel_Proof_Notice.pdf"
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }
}
