import SwiftUI

struct Contact:View {
  var body: some View{
    VStack(alignment:.leading,spacing:10){
    Text("Contact")
      .font(.largeTitle)
      .fontWeight(.bold)
      .font(.system(size: 24))
    Text("Address")
      .font(.headline)
      .fontWeight(.bold)
      .font(.system(size: 20))
    Text("H.No.123/12,Lakdikapool,Hyderebad")
      .font(.title)
      .font(.system(size: 20))
    Text("Phone:8901234567")
      .font(.title)
      .font(.system(size: 20))
    }
  }
}
#Preview {
  Contact()
}
