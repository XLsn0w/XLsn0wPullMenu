
#import <Foundation/Foundation.h>

@protocol XLsn0wConvertDelegate <NSObject>

// key是数组时使用, 提供一个协议，只要准备这个协议的类，都能把数组中的字典转模型
// 用在三级数组转换
@optional
+ (NSDictionary *_Nullable)modifyModelKeyIsNSArrayScheme;

@end

@interface NSObject (XLsn0wModel) <XLsn0wConvertDelegate>

// 字典转模型
+ (instancetype _Nullable )convertModelWithDictionary:(NSDictionary *_Nullable)dictionary;


+ (instancetype _Nullable )xlsn0w_modelWithDictionary:(NSDictionary *_Nonnull)dictionary;///一级转换

+ (NSDictionary *_Nullable)convertToDictionaryFromJSON:(id _Nullable)JSON;

@end
