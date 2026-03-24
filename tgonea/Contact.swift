import SwiftUI

struct Contact: View {
    var body: some View {
        ZStack {
            AppScreenBackground()

            ScrollView {
                VStack(spacing: 18) {
                    AppSectionHeader(
                        eyebrow: "Contact",
                        title: "Reach the association office easily",
                        subtitle: "Use the details below for office visits, quick calls, or formal communication."
                    )
                    .padding(.top, 16)
                    .stagedAppear()

                    VStack(alignment: .leading, spacing: 18) {
                        contactRow(
                            icon: "mappin.and.ellipse",
                            title: "Office Address",
                            detail: "H.No.123/12, Lakdikapool, Hyderabad"
                        )

                        contactRow(
                            icon: "phone.fill",
                            title: "Phone",
                            detail: "8901234567"
                        )

                        contactRow(
                            icon: "clock.fill",
                            title: "Availability",
                            detail: "Monday to Friday, 10:00 AM to 5:00 PM"
                        )
                    }
                    .padding(20)
                    .appCardStyle()
                    .stagedAppear(0.08)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Need help?")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        Text("For member records, circulars, or association updates, the office desk can guide you to the right contact quickly.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.softText)
                    }
                    .padding(20)
                    .appGlassCardStyle()
                    .stagedAppear(0.14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .font(.system(.body, design: .rounded))
    }

    private func contactRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
                Text(detail)
                    .font(.body)
                    .foregroundStyle(AppTheme.softText)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        Contact()
    }
}
