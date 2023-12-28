# resource "gdrive_drive" "pva_drive" {
#     name = "PVA"
# }

# resource "gdrive_file" "folder_1" {
#   mime_type = "application/vnd.google-apps.folder"
#   drive_id  = resource.gdrive_drive.pva_drive.id
#   name      = "base_videos"
# #   parent    = "..."
# }