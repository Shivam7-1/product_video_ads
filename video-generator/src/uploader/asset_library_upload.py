
from google.ads.googleads.client import GoogleAdsClient\

class AssetLibraryUploader():

    def __init__(self, credentials, customer_id, developer_token):
        self.customer_id = customer_id
        self.ads_credentials = {
            "developer_token": developer_token,
            "refresh_token": credentials.refresh_token,
            "client_id": credentials.client_id,
            "client_secret": credentials.client_secret,
            "use_proto_plus": True
        }

    def upload_video_asset(video_id):
        # Add the YouTube video asset to the asset library.
        client = GoogleAdsClient.load_from_dict(self.ads_credentials)

        asset_service = client.get_service("AssetService")
        asset_operation = client.get_type("AssetOperation")
        asset = asset_operation.create
        asset.type_ = client.enums.AssetTypeEnum.YOUTUBE_VIDEO
        asset.youtube_video_asset.youtube_video_id=video_id
        
        # Add the asset to the asset library.
        mutate_asset_response = asset_service.mutate_assets(
            customer_id=self.customer_id,
            operations=[asset_operation]
        )
