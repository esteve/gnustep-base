#import <Foundation/Foundation.h>
#import "Testing.h"
#import "ObjectTesting.h"

#if     GNUSTEP
extern const char *GSPathHandling(const char *);
#endif

int main()
{
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];
  NSURL		*url;
  NSURL		*rel;
  NSData	*data;
  NSString	*str;
  NSNumber      *num;
  unsigned      i;
  unichar	u = 163;
  unichar       buf[256];
  
  TEST_FOR_CLASS(@"NSURL", [NSURL alloc],
    "NSURL +alloc returns an NSURL");
  
  TEST_FOR_CLASS(@"NSURL", [NSURL fileURLWithPath: @"."],
    "NSURL +fileURLWithPath: returns an NSURL");
  
  TEST_FOR_CLASS(@"NSURL", [NSURL URLWithString: @"http://www.w3.org/"],
    "NSURL +URLWithString: returns an NSURL");
  
  str = [NSString stringWithCharacters: &u length: 1];
  url = [NSURL fileURLWithPath: str];
  str = [[[NSFileManager defaultManager] currentDirectoryPath]
    stringByAppendingPathComponent: str];
  PASS([[url path] isEqual: str], "Can put a pound sign in a file URL");
  
  str = [url scheme];
  PASS([str isEqual: @"file"], "Scheme of file URL is file");

  url = [NSURL URLWithString: @"http://www.w3.org/"];
  data = [url resourceDataUsingCache: NO];
  PASS(data != nil,
    "Can load a page from www.w3.org");
  num = [url propertyForKey: NSHTTPPropertyStatusCodeKey];
  PASS([num isKindOfClass: [NSNumber class]] && [num intValue] == 200,
    "Status of load is 200 for www.w3.org");

  url = [NSURL URLWithString:@"this isn't a URL"];
  PASS(url == nil, "URL with 'this isn't a URL' returns nil");

  url = [NSURL URLWithString: @"http://www.w3.org/silly-file-name"];
  data = [url resourceDataUsingCache: NO];
  num = [url propertyForKey: NSHTTPPropertyStatusCodeKey];
  PASS([num isKindOfClass: [NSNumber class]] && [num intValue] == 404,
    "Status of load is 404 for www.w3.org/silly-file-name");

  str = [url scheme];
  PASS([str isEqual: @"http"],
       "Scheme of http://www.w3.org/silly-file-name is http");
  str = [url host];
  PASS([str isEqual: @"www.w3.org"],
    "Host of http://www.w3.org/silly-file-name is www.w3.org");
  str = [url path];
  PASS([str isEqual: @"/silly-file-name"],
    "Path of http://www.w3.org/silly-file-name is /silly-file-name");
  PASS([[url resourceSpecifier] isEqual: @"//www.w3.org/silly-file-name"],
    "resourceSpecifier of http://www.w3.org/silly-file-name is //www.w3.org/silly-file-name");


  url = [NSURL URLWithString: @"http://www.w3.org/silly-file-path/"];
  str = [url path];
  PASS([str isEqual: @"/silly-file-path"],
    "Path of http://www.w3.org/silly-file-path/ is /silly-file-path");
  PASS([[url resourceSpecifier] isEqual: @"//www.w3.org/silly-file-path/"],
    "resourceSpecifier of http://www.w3.org/silly-file-path/ is //www.w3.org/silly-file-path/");

  str = [url absoluteString];
  PASS([str isEqual: @"http://www.w3.org/silly-file-path/"],
    "Abs of http://www.w3.org/silly-file-path/ is correct");

#if	defined(__MINGW32__)
  url = [NSURL fileURLWithPath: @"C:\\WINDOWS"];
  str = [url path];
  PASS_EQUAL(str, @"C:\\WINDOWS",
    "Path of file URL C:\\WINDOWS is C:\\WINDOWS");
  PASS_EQUAL([url description], @"file://localhost/C:%5CWINDOWS/",
    "File URL C:\\WINDOWS is file://localhost/C:%%5CWINDOWS/");
  PASS_EQUAL([url resourceSpecifier], @"//localhost/C:%5CWINDOWS/",
    "resourceSpecifier of C:\\WINDOWS is //localhost/C:%%5CWINDOWS/");
#else
  url = [NSURL fileURLWithPath: @"/usr"];
  str = [url path];
  PASS_EQUAL(str, @"/usr", "Path of file URL /usr is /usr");
  PASS_EQUAL([url description], @"file://localhost/usr/",
    "File URL /usr is file://localhost/usr/");
  PASS_EQUAL([url resourceSpecifier], @"//localhost/usr/",
    "resourceSpecifier of /usr is //localhost/usr/");
#endif

  url = [NSURL URLWithString: @"file:///usr"];
  PASS_EQUAL([url resourceSpecifier], @"/usr",
    "resourceSpecifier of file:///usr is /usr");

  url = [NSURL URLWithString: @"http://here.and.there/testing/one.html"];
  rel = [NSURL URLWithString: @"aaa/bbb/ccc/" relativeToURL: url];
  PASS_EQUAL([rel absoluteString],
    @"http://here.and.there/testing/aaa/bbb/ccc/",
    "Simple relative URL absoluteString works");
  PASS_EQUAL([rel path], @"/testing/aaa/bbb/ccc",
    "Simple relative URL path works");
#if     GNUSTEP
  PASS_EQUAL([rel fullPath], @"/testing/aaa/bbb/ccc/",
    "Simple relative URL fullPath works");
#endif

  url = [NSURL URLWithString: @"http://here.and.there/testing/one.html"];
  rel = [NSURL URLWithString: @"/aaa/bbb/ccc/" relativeToURL: url];
  PASS([[rel absoluteString]
    isEqual: @"http://here.and.there/aaa/bbb/ccc/"],
    "Root relative URL absoluteString works");
  PASS([[rel path]
    isEqual: @"/aaa/bbb/ccc"],
    "Root relative URL path works");
#if     GNUSTEP
  PASS([[rel fullPath]
    isEqual: @"/aaa/bbb/ccc/"],
    "Root relative URL fullPath works");
#endif

  url = [NSURL URLWithString: @"/aaa/bbb/ccc/"];
  PASS([[url absoluteString] isEqual: @"/aaa/bbb/ccc/"],
    "absolute root URL absoluteString works");
  PASS([[url path] isEqual: @"/aaa/bbb/ccc"],
    "absolute root URL path works");
#if     GNUSTEP
  PASS([[url fullPath] isEqual: @"/aaa/bbb/ccc/"],
    "absolute root URL fullPath works");
#endif

  url = [NSURL URLWithString: @"aaa/bbb/ccc/"];
  PASS([[url absoluteString] isEqual: @"aaa/bbb/ccc/"],
    "absolute URL absoluteString works");
  PASS([[url path] isEqual: @"aaa/bbb/ccc"],
    "absolute URL path works");
#if     GNUSTEP
  PASS([[url fullPath] isEqual: @"aaa/bbb/ccc/"],
    "absolute URL fullPath works");
#endif

  url = [NSURL URLWithString: @"http://127.0.0.1/"];
  PASS([[url absoluteString] isEqual: @"http://127.0.0.1/"],
    "absolute http URL absoluteString works");
  PASS([[url path] isEqual: @"/"],
    "absolute http URL path works");
#if     GNUSTEP
  PASS([[url fullPath] isEqual: @"/"],
    "absolute http URL fullPath works");
#endif

  url = [NSURL URLWithString: @"http://127.0.0.1/ hello"];
  PASS(url == nil, "space is illegal");

  url = [NSURL URLWithString: @""];
  PASS([[url absoluteString] isEqual: @""],
    "empty string gives empty URL");
  PASS([url path] == nil,
    "empty string gives nil path");
  PASS([url scheme] == nil,
    "empty string gives nil scheme");

  url = [NSURL URLWithString: @"aaa%20ccc/"];
  PASS([[url absoluteString] isEqual: @"aaa%20ccc/"],
    "absolute URL absoluteString works with encoded space");
  PASS([[url path] isEqual: @"aaa ccc"],
    "absolute URL path decodes space");

  url = [NSURL URLWithString: @"/?aaa%20ccc"];
  PASS([[url query] isEqual: @"aaa%20ccc"],
    "escapes are not decoded in query");

  url = [NSURL URLWithString: @"/#aaa%20ccc"];
  PASS([[url fragment] isEqual: @"aaa%20ccc"],
    "escapes are not decoded in fragment");

  url = [NSURL URLWithString: @"/tmp/xxx"];
  PASS([[url path] isEqual: @"/tmp/xxx"] && [url scheme] == nil,
    "a simple path becomes a simple URL");

  url = [NSURL URLWithString: @"filename"];
  PASS([[url path] isEqual: @"filename"] && [url scheme] == nil,
    "a simple file name becomes a simple URL");

  url = [NSURL URLWithString: @"file://localhost/System/Library/"
    @"Documentation/Developer/Gui/Reference/index.html"]; 

  str = @"NSApplication.html"; 
  rel = [NSURL URLWithString: str relativeToURL: url]; 
//NSLog(@"with link %@, obtained URL: %@ String: %@", str, rel, [rel absoluteString]); 
  PASS([[rel absoluteString] isEqual: @"file://localhost/System/Library/Documentation/Developer/Gui/Reference/NSApplication.html"], "Adding a relative file URL works");
  str = @"NSApplication.html#class$NSApplication"; 
  rel = [NSURL URLWithString: str relativeToURL: url]; 
//NSLog(@"with link %@, obtained URL: %@ String: %@", str, rel, [rel absoluteString]); 
  PASS([[rel absoluteString] isEqual: @"file://localhost/System/Library/Documentation/Developer/Gui/Reference/NSApplication.html#class$NSApplication"], "Adding relative file URL with fragment works");

#if	defined(__MINGW32__)
GSPathHandling("unix");
#endif

  buf[0] = '/';
  for (i = 1; i < 256; i++)
    {
      buf[i] = i;
    }
  str = [NSString stringWithCharacters: buf length: 256];
  url = [NSURL fileURLWithPath: str];
  NSLog(@"path quoting %@", [url absoluteString]);
  PASS_EQUAL([url absoluteString],
    @"file://localhost/%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F%20!%22%23$%25&'()*+,-./0123456789:%3B%3C=%3E%3F@ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~%7F%C2%80%C2%81%C2%82%C2%83%C2%84%C2%85%C2%86%C2%87%C2%88%C2%89%C2%8A%C2%8B%C2%8C%C2%8D%C2%8E%C2%8F%C2%90%C2%91%C2%92%C2%93%C2%94%C2%95%C2%96%C2%97%C2%98%C2%99%C2%9A%C2%9B%C2%9C%C2%9D%C2%9E%C2%9F%C2%A0%C2%A1%C2%A2%C2%A3%C2%A4%C2%A5%C2%A6%C2%A7%C2%A8%C2%A9%C2%AA%C2%AB%C2%AC%C2%AD%C2%AE%C2%AF%C2%B0%C2%B1%C2%B2%C2%B3%C2%B4%C2%B5%C2%B6%C2%B7%C2%B8%C2%B9%C2%BA%C2%BB%C2%BC%C2%BD%C2%BE%C2%BF%C3%80%C3%81%C3%82%C3%83%C3%84%C3%85%C3%86%C3%87%C3%88%C3%89%C3%8A%C3%8B%C3%8C%C3%8D%C3%8E%C3%8F%C3%90%C3%91%C3%92%C3%93%C3%94%C3%95%C3%96%C3%97%C3%98%C3%99%C3%9A%C3%9B%C3%9C%C3%9D%C3%9E%C3%9F%C3%A0%C3%A1%C3%A2%C3%A3%C3%A4%C3%A5%C3%A6%C3%A7%C3%A8%C3%A9%C3%AA%C3%AB%C3%AC%C3%AD%C3%AE%C3%AF%C3%B0%C3%B1%C3%B2%C3%B3%C3%B4%C3%B5%C3%B6%C3%B7%C3%B8%C3%B9%C3%BA%C3%BB%C3%BC%C3%BD%C3%BE%C3%BF", "path quoting");

  /* Test +fileURLWithPath: for messy/complex path
   */
  url = [NSURL fileURLWithPath: @"/this#is a Path with % + = & < > ?"];
  PASS_EQUAL([url path], @"/this#is a Path with % + = & < > ?",
    "complex -path");
  PASS_EQUAL([url fragment], nil, "complex -fragment");
  PASS_EQUAL([url parameterString], nil, "complex -parameterString");
  PASS_EQUAL([url query], nil, "complex -query");
  PASS_EQUAL([url absoluteString], @"file://localhost/this%23is%20a%20Path%20with%20%25%20+%20=%20&%20%3C%20%3E%20%3F", "complex -absoluteString");
  PASS_EQUAL([url relativeString], @"file://localhost/this%23is%20a%20Path%20with%20%25%20+%20=%20&%20%3C%20%3E%20%3F", "complex -relativeString");
  PASS_EQUAL([url description], @"file://localhost/this%23is%20a%20Path%20with%20%25%20+%20=%20&%20%3C%20%3E%20%3F", "complex -description");

#if	defined(__MINGW32__)
GSPathHandling("right");
#endif

  /* Test +URLWithString: for file URL with a messy/complex path
   */
  url = [NSURL URLWithString: @"file:///pathtofile;parameters?query#anchor"];
  PASS(nil == [url host], "host");
  PASS(nil == [url user], "user");
  PASS(nil == [url password], "password");
  PASS([@"/pathtofile;parameters?query#anchor"
    isEqual: [url resourceSpecifier]], "resourceSpecifier");
  PASS([@"/pathtofile" isEqual: [url path]], "path");
  PASS([@"query" isEqual: [url query]], "query");
  PASS([@"parameters" isEqual: [url parameterString]], "parameterString");
  PASS([@"anchor" isEqual: [url fragment]], "fragment");
  PASS([@"file:///pathtofile;parameters?query#anchor"
    isEqual: [url absoluteString]], "absoluteString");
  PASS([@"/pathtofile" isEqual: [url relativePath]], "relativePath");
  PASS([@"file:///pathtofile;parameters?query#anchor"
    isEqual: [url description]], "description");

  url = [NSURL URLWithString: @"file:///pathtofile; parameters? query #anchor"];     // can't initialize with spaces (must be %20)
  PASS(nil == url, "url with spaces");
  url = [NSURL URLWithString: @"file:///pathtofile;%20parameters?%20query%20#anchor"];
  PASS(nil != url, "url without spaces");

  str = [[NSFileManager defaultManager] currentDirectoryPath];
  str = [str stringByAppendingPathComponent: @"basic.m"];
  url = [NSURL fileURLWithPath: str];
  PASS([url resourceDataUsingCache: NO] != nil, "can load file URL");
  str = [str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
  str = [NSString stringWithFormat: @"file://localhost/%@#anchor", str];
  url = [NSURL URLWithString: str];
  PASS([url resourceDataUsingCache: NO] != nil,
    "can load file URL with anchor");


  [arp release]; arp = nil;
  return 0;
}