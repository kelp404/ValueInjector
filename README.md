#ValueInjector
http://kelp.phate.org/2012/05/inject-value-from-nsdictionary-to.html

Kelp http://kelp.phate.org/ <br/>
MIT License


Cocoa ValueInjector provides converting weak typing to strong typing.

It includes two function injecting value from NSDictionary to custom class and initialization NSDictionary with custom class.

After import ValueInjector.h, NSObject will be add a new message "injectFromObject", and NSDictionary will be add a new message "initWithObject".

**injectFromObject** converts weak typing to strong typing. When you use JSONKit parsing json then get a NSDictionary object, you can use injectFromObject to convert NSDictionary to custom class.

**initWithObject** converts custom class to NSDictionary. When you want to serialize custom class(strong typing), you can use initWithObject to initialize NSDictionary with custom class.


##Inject value from NSDictionary to custom class

```objective-c
NSObject (ValueInjector)
- (id)injectFromObject:(NSObject *)object;
```
```objective-c
NSDictionary *dictionary = [[[NSDictionary alloc] init] ...];
YourClass *model = [[YourClass alloc] init];
[model inijectFromObject:dictionary];
```


##Initialize NSDictionary with custom class

```objective-c
NSDictionary (ValueInjector)
- (id)initWithObject:(NSObject *)object;
```
```objective-c
YourClass *model = [[YourClass alloc] init];
// set value of model ...
NSDictionary *dictionary = [[NSDictionary alloc] initWithObject:model];
```

Cocoa Reflection Refer: https://developer.apple.com/library/mac/#documentation/cocoa/Reference/ObjCRuntimeRef/Reference/reference.html