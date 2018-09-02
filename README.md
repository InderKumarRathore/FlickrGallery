# FlickrImage
This sample project shows the images from flickr base on search text

## NOTE
- Use device if possible, my simulator (on my system) was very slow. Thus app seems to be unresponsive. But on iPhone 5s it is very smooth.
- User software keyboard's search button to search if you're running sample on simulator


## Feature

- Lazy loading in collection view
- Image Caching (Memory and Disk)
- Used prefetching in collection view (new in iOS 10)
- Used ImageIO's `CGImageSourceCreateThumbnailAtIndex` to down sample images efficiently
- Used concurrent `Operation`, because apple has deprecated the synchronous download of data
- Followed [VIP architecture](https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf) (Similar to VIPER) 

## Enhancement

- Right now we can search if there is existing search going on
- In `ImageFetcher` class there we're loading images from disk on a serial queue. It can be improved
- There is a general error message for all the server errors, can be improved
- 

## License


MIT


**Free Software, Hell Yeah!**

