import SwiftUI

struct Contact:View {
  var body: some View{
      
          
          VStack(alignment:.leading,spacing:10){
              Text("Contact")
                  .font(.title)
                  .fontWeight(.bold)
                  .font(.system(size: 24))
              Text("Address")
                  .font(.title3)
                  .fontWeight(.bold)
                  .font(.system(size: 20))
              Text("H.No.123/12,Lakdikapool,Hyderebad")
                  .font(.headline)
                  .font(.system(size: 10))
              Text("Phone:8901234567")
                  .font(.headline)
                  .font(.system(size: 10))
          
    }
    .frame(width:400,height:600,alignment: .topLeading)
  }
}
#Preview {
  Contact()
}
