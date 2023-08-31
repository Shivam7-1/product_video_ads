from google_auth_oauthlib.flow import InstalledAppFlow
import google.oauth2.credentials
import google_auth_oauthlib.flow

SCOPES = ['https://www.googleapis.com/auth/youtube']

def main():
    flow = InstalledAppFlow.from_client_secrets_file(
        'client_secrets.json',
        scopes=SCOPES)
    flow.run_console()


if __name__ == '__main__':
    main()

