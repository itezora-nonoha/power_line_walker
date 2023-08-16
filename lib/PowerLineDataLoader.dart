// ignore: file_names
import 'dart:io';

import 'package:http/http.dart' as http;

class PowerLineDataLoader {
  
  static const scriptId = 'AKfycbyBc4K0t2n_6itPUyZASY4tWiX359YRuSLb-bGS4Gqkvtb-nSfx7jOm40Y5uoBn_t1nBg';
  static const clientId = '605096543498-4aqdq4f8i9engnj97ddne586oj4odgi4.apps.googleusercontent.com';
  static const clientSecret = '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';
  String refreshToken = '1//04ZOWAdQhLi39CgYIARAAGAQSNwF-L9IrCyUSUL78xmZS3y-eU_w3K8v5AYI6kAmSMicEpsxO0OZVUSE3iUYlkv1iJseXfR3TTKY';
  // static const urlString = 'https://script.googleapis.com/v1/scripts/${scriptId}:run';
  static const authCode = '4/0Adeu5BW7TybL0vs2xLxTSBhHa7Jo56Arja0mlT8qediDgU7bAe3-Ugmaj8xPO0bfkngVlw';
  String accessToken = '';

//   Future<void> getAuhCode() async {
//     var urlstr = 'https://accounts.google.com/o/oauth2/v2/auth';
// scope=スコープ
// &access_type=offline
// &include_granted_scope=true
// &response_type=code
// &redirect_uri=手順１で設定したリダイレクトURI
// &client_id=手順１で取得したクライアントID-d code=手順2で取得した認可コード 
// -d client_id=クライアントID
// -d client_secret=クライアントシークレット
// -dredirect_uri=リダイレクトURI
// -d grant_type=authorization_code 

  Future<void> getAuthCode() async{
    String urlString = 'https://accounts.google.com/o/oauth2/auth?client_id=${clientId}&include_granted_scope=true&response_type=code&scope=https://www.googleapis.com/auth/spreadsheets';
    Uri url = Uri.parse(urlString);
    var response = await http.post(url);
    print("testf");
    print(response.body);
  }

  Future<void> getAccessToken() async{
    String urlString = 'https://accounts.google.com/o/oauth2/token';
    // String urlString = 'https://accounts.google.com/o/oauth2/v2/auth?';
    Uri url = Uri.parse(urlString);
    var response = await http.post(url, body: {
      'code': authCode,
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': 'https://developers.google.com/oauthplayground',
      'grant_type': 'authorization_code'
    });
    print("testf");
    print(response.body);
    //     Uri url = Uri.parse(urlString);
    // var response = await http.post(url, body: {
      // 'client_id': clientId,
      // 'client_secret': clientSecret,
      // 'refresh_token': refreshToken,
      // 'grant_type': 'refresh_token',
    // });

    //   'code': authCode,
    //   'client_id': clientId,
    //   'client_secret': clientSecret,
    //   'refresh_token': refreshToken,
    //   'redirect_url': 
    //   'grant_type': 'authorization_code',
    // });
  }

}

void main(){
  print("testfdd");
  PowerLineDataLoader dl = PowerLineDataLoader();
  dl.getAccessToken();
  // dl.getAuthCode();
}
// // const REFRESH_TOKEN = 'リフレッシュトークン(OAuth 2.0 Playgroundで取得したrefresh_token)'
// async function main() {
//   try {
//     // アクセストークンを取得する(Promise)
//     const accessToken = await getAccessToken().(function (res) {
//       return res
//     })
    
//     // GASを実行
//     const urlString = 'https://script.googleapis.com/v1/scripts/${SCRIPT_ID}:run';
//     Uri url = Uri.parse(urlString);
//     const data = JSON.stringify({
//       function: 'myFunction'
//     });
//     const options = {
//       method: "POST",
//       headers: {
//         Authorization: `Bearer ${accessToken}`,
//       },
//     };
//     const reque = https.request(url, options, res=>{
//       res.on('data', (chunk) => {
//         //GASからのreturnデータ
//         console.log('RESPONSE: ' + chunk)
//       });
//     });
//     reque.write(data)
//     reque.end()
//   } catch (e) {
//     throw e
//   }
// }
// /**
//  * アクセストークンを取得する関数
//  * @return string
//  */
// async function getAccessToken(){
//   return new Promise(function (resolve) {
//     const data = JSON.stringify({
//       client_id: CLIENT_ID,
//       client_secret: CLIENT_SECRET,
//       refresh_token: REFRESH_TOKEN,
//       grant_type: 'refresh_token',
//     });
//     const options = {
//       method: "POST",
//       headers: {
//         "Content-Type": "application/json",
//       },
//     };
//     const reque = https.request(TOKEN_URL, options, (res)=>{
//       // console.log(res)
//       res.on('data', (chunk) => {
//         let access_token = JSON.parse(chunk.toString())
//         resolve(access_token.access_token)
//       })
//     })
//     reque.write(data)
//     reque.end()
//   })
// }
// main()

// }
