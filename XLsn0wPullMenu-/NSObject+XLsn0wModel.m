
#import "NSObject+XLsn0wModel.h"
#import <objc/message.h>

const char *kPropertyListKey1_char = "CMPropertyListKey1";

@implementation NSObject (XLsn0wModel)

#pragma mark - JSON格式转换成iOS字典格式
+ (NSDictionary *_Nullable)convertToDictionaryFromJSON:(id _Nullable)JSON {
    if (!JSON || JSON == (id)kCFNull) return nil;
    NSDictionary *JSON2Dictionary = nil;
    NSData *jsonData = nil;
    if ([JSON isKindOfClass:[NSDictionary class]]) {
        JSON2Dictionary = JSON;
    } else if ([JSON isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)JSON dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([JSON isKindOfClass:[NSData class]]) {
        jsonData = JSON;
    }
    if (jsonData) {
        JSON2Dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![JSON2Dictionary isKindOfClass:[NSDictionary class]]) JSON2Dictionary = nil;
    }
    return JSON2Dictionary;
}


/*
 * 把字典中所有value给模型中属性赋值,
 * KVC:遍历字典中所有key,去模型中查找
 * Runtime:根据模型中属性名去字典中查找对应value,如果找到就给模型的属性赋值.
 */
// 字典转模型
+ (instancetype)convertModelWithDictionary:(NSDictionary *)dictionary {
    // 创建对应模型对象
    id obj = [[self alloc] init];
    
    unsigned int count = 0;
    
    // 1.获取成员属性数组
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    // 2.遍历所有的成员属性名,一个一个去字典中取出对应的value给模型属性赋值
    for (int i = 0; i < count; i++) {
        
        // 2.1 获取成员属性
        Ivar ivar = ivarList[i];
        
        // 2.2 获取成员属性名 C -> OC 字符串
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 2.3 _成员属性名 => 字典key
        NSString *key = [ivarName substringFromIndex:1];
        
        // 2.4 去字典中取出对应value给模型属性赋值
        id value = dictionary[key];
        
        
        // 获取成员属性类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        // 二级转换,字典中还有字典,也需要把对应字典转换成模型
        //
        // 判断下value,是不是字典
        if ([value isKindOfClass:[NSDictionary class]] && ![ivarType containsString:@"NS"]) { //  是字典对象,并且属性名对应类型是自定义类型
            // user User
            
            // 处理类型字符串 @\"User\" -> User
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
            ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            // 自定义对象,并且值是字典
            // value:user字典 -> User模型
            // 获取模型(user)类对象
            Class modalClass = NSClassFromString(ivarType);
            
            // 字典转模型
            if (modalClass) {
                // 字典转模型 user
                value = [modalClass convertModelWithDictionary:value];
            }
            
            // 字典,user
            //            HLLog(@"%@",key);
        }
        
        // 三级转换：NSArray中也是字典，把数组中的字典转换成模型.
        // 判断值是否是数组
        if ([value isKindOfClass:[NSArray class]]) {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(modifyModelKeyIsNSArrayScheme)]) {
                
                // 转换成id类型，就能调用任何对象的方法
                id idSelf = self;
                
                // 获取数组中字典对应的模型
                NSString *type =  [idSelf modifyModelKeyIsNSArrayScheme][key];
                
                // 生成模型
                Class classModel = NSClassFromString(type);
                NSMutableArray *arrM = [NSMutableArray array];
                // 遍历字典数组，生成模型数组
                for (NSDictionary *dict in value) {
                    // 字典转模型
                    id model =  [classModel convertModelWithDictionary:dict];
                    [arrM addObject:model];
                }
                
                // 把模型数组赋值给value
                value = arrM;
                
            }
        }
        
        // 2.5 KVC字典转模型
        if (value) {
            [obj setValue:value forKey:key];
        }
    }
    
    
    // 返回对象
    return obj;
    
}

///一级转换
+ (instancetype)xlsn0w_modelWithDictionary:(NSDictionary *)dictionary {
    /* 实例化对象 */
    id model = [[self alloc]init];
    
    /* 使用字典,设置对象信息 */
    /* 1. 获得 self 的属性列表 */
    NSArray *propertyList = [self xlsn0w_objcProperties];
    
    /* 2. 遍历字典 */
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        /* 3. 判断 key 是否字 propertyList 中 */
        if ([propertyList containsObject:key]) {
            
            // KVC字典转模型
            if (obj) {
                /* 说明属性存在,可以使用 KVC 设置数值 */
                [model setValue:obj forKey:key];
            }
        }
        
    }];
    
    /* 返回对象 */
    return model;
}

+ (NSArray *)xlsn0w_objcProperties
{
    /* 获取关联对象 */
    NSArray *ptyList = objc_getAssociatedObject(self, kPropertyListKey1_char);
    
    /* 如果 ptyList 有值,直接返回 */
    if (ptyList) {
        return ptyList;
    }
    /* 调用运行时方法, 取得类的属性列表 */
    /* 成员变量:
     * class_copyIvarList(__unsafe_unretained Class cls, unsigned int *outCount)
     * 方法:
     * class_copyMethodList(__unsafe_unretained Class cls, unsigned int *outCount)
     * 属性:
     * class_copyPropertyList(__unsafe_unretained Class cls, unsigned int *outCount)
     * 协议:
     * class_copyProtocolList(__unsafe_unretained Class cls, unsigned int *outCount)
     */
    unsigned int outCount = 0;
    /**
     * 参数1: 要获取得类
     * 参数2: 雷属性的个数指针
     * 返回值: 所有属性的数组, C 语言中,数组的名字,就是指向第一个元素的地址
     */
    /* retain, creat, copy 需要release */
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    
    NSMutableArray *mtArray = [NSMutableArray array];
    
    /* 遍历所有属性 */
    for (unsigned int i = 0; i < outCount; i++) {
        /* 从数组中取得属性 */
        objc_property_t property = propertyList[i];
        /* 从 property 中获得属性名称 */
        const char *propertyName_C = property_getName(property);
        /* 将 C 字符串转化成 OC 字符串 */
        NSString *propertyName_OC = [NSString stringWithCString:propertyName_C encoding:NSUTF8StringEncoding];
        [mtArray addObject:propertyName_OC];
    }
    
    /* 设置关联对象 */
    /**
     *  参数1 : 对象self
     *  参数2 : 动态添加属性的 key
     *  参数3 : 动态添加属性值
     *  参数4 : 对象的引用关系
     */
    
    objc_setAssociatedObject(self, kPropertyListKey1_char, mtArray.copy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    /* 释放 */
    free(propertyList);
    return mtArray.copy;
    
}


@end
