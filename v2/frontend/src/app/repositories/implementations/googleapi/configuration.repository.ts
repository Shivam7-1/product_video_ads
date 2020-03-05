/* 
   Copyright 2020 Google LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

   https://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import { Injectable } from '@angular/core';
import { GoogleAPI } from './GoogleAPI';
import { environment } from 'environments/environment';
import { ConfigurationInterface } from 'app/repositories/configuration.interface';
import { Product } from 'app/models/product';
import { OfferType } from 'app/models/offertype';
import { Video } from 'app/models/video';
import { Asset } from 'app/models/asset';
import { Base } from 'app/models/base';

@Injectable({providedIn: 'root'})
export class ConfigurationRepository implements ConfigurationInterface {

    constructor(public googleApi : GoogleAPI) {}

    async load_fonts(): Promise<object> {
        
        const drive_folder = await this.load_drive_folder()
        const fonts = (await this.googleApi.list_files_from_folder(drive_folder, 'fonts')) || []

        // Downloads font file
        for (let [font_name, id] of Object.entries(fonts))
            fonts[font_name] = (await this.googleApi.download_file(id as string))

        return fonts
    }

    async upload_base_file(file : File) : Promise<any> {

        const drive_folder = await this.load_drive_folder()
        const folders = await this.googleApi.list_files_from_folder(drive_folder, '')

        return this.googleApi.upload_file(file, folders['base_videos'])
    }

    async load_bases(): Promise<Base[]> {

        const bases = ((await this.googleApi.get_values(environment.configuration.bases_range)).map(Base.from_base_array) || []) as Base[]
        
        const drive_folder = await this.load_drive_folder()
        const base_videos = (await this.googleApi.list_files_from_folder(drive_folder, 'base_videos')) || []
        
        for (let base of bases)
            base.url = environment.drive_file_prefix + base_videos[base.file]

        return bases
    }
    
    async load_drive_folder(): Promise<string> {
        return (await this.googleApi.get_values(environment.configuration.drive_folder))[0][0]
    }

    async load_assets(): Promise<Asset[]> {
        const assets = (await this.googleApi.get_values(environment.configuration.static_assets)) || []
        return assets.map(Asset.from_asset_array)
    }

    async load_products() : Promise<Product[]> {

        const products_array = (await this.googleApi.get_values(environment.configuration.product_range)) || []

        // No products to parse
        if (products_array.length == 0)
            return products_array

        // Parse products array and header to map object
        const header : Array<string> = products_array.shift().slice(4) // Remove 4 first columns as they are properties
        const products : Array<Product> = []

        // Each product
        for(let product of products_array) {

            const id = product.shift()
            const group = product.shift()
            const offer_type = product.shift()
            const position = product.shift()
            const values : object = {}

            for(let i = 0; i < product.length; i++)
                values[header[i]] = product[i]

            products.push(new Product(id, group, offer_type, position, values))
        }

        return products
    }    
    
    async load_offer_types(): Promise<OfferType[]> {
        const offer_types = (await this.googleApi.get_values(environment.configuration.offer_types_range)) || []
        return offer_types.map(OfferType.from_offertype_array)
    }

    async load_videos() : Promise<Video[]> {
        const videos = (await this.googleApi.get_values(environment.configuration.campaign_range)) || []
        return videos.map(Video.from_video_array)
    }

    async save_bases(bases: Base[]): Promise<any> {

        const data = []
  
        data.push({
          range: environment.configuration.bases_range,
          values: bases.map(Base.to_base_array)
        })
      
        return this.googleApi.save_values(data)
    }

    async save_assets(assets: Asset[]): Promise<any> {

        const data = []
  
        data.push({
          range: environment.configuration.static_assets,
          values: assets.map(Asset.to_asset_array)
        })
      
        return this.googleApi.save_values(data)
    }

    async save_products(products: Product[]): Promise<any> {
        
        // TODO: IMPLEMENT
        
        /*const data = []
  
        data.push({
          range: environment.configuration.product_range,
          values: products.map(Product.to_product_array)
        })
      
        return this.googleApi.save_values(data)*/
    }

    async save_offer_types(offer_types: OfferType[]): Promise<any> {

        const data = []
  
        data.push({
            range: environment.configuration.offer_types_range,
            values: offer_types.map(OfferType.to_offertype_array)
        })
        
        return this.googleApi.save_values(data)
    }

    async save_videos(videos: Video[]): Promise<any> {

        const data = []
  
        data.push({
            range: environment.configuration.campaign_range,
            values: videos.map(Video.to_video_array)
        })
        
        return this.googleApi.save_values(data)
    }
}