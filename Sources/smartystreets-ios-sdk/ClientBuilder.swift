import Foundation

@objcMembers class ClientBuilder: NSObject {
    //    The ClientBuilder class helps you build a client object for one of the supported SmartyStreets APIs.
    //    You can use ClientBuilder's methods to customize settings like maximum retries or timeout duration.
    //    These methods are chainable, so you can usually get set up with one line of code.
    
    var signer:SmartyCredentials!
    var serializer:SmartySerializer
    var sender:SmartySender!
    var maxRetries:Int = 5
    var maxTimeout:Int = 10000
    var debug:Bool = false
    var urlPrefix:String!
    var proxy:NSDictionary!
    var internationalStreetApiURL:String = "https://international-street.api.smartystreets.com/verify"
    var usAutocompleteApiURL:String = "https://us-autocomplete.api.smartystreets.com/suggest"
    var usExtractApiURL:String = "https://us-extract.api.smartystreets.com"
    var usStreetApiURL:String = "https://us-street.api.smartystreets.com/street-address"
    var usZipCodeApiURL:String = "https://us-zipcode.api.smartystreets.com/lookup"
    
    override init() {
        self.serializer = SmartySerializer()
    }
    
    init(signer:SmartyCredentials) {
        self.signer = signer
        self.serializer = SmartySerializer()
    }
    
    init(authId:String, authToken:String) {
        self.signer = StaticCredentials(authId: authId, authToken: authToken)
        self.serializer = SmartySerializer()
    }
    
    init(id:String, hostname:String) {
        self.signer = SharedCredentials(id: id, hostname: hostname)
        self.serializer = SmartySerializer()
    }
    
    func retryAtMost(maxRetries:Int) -> ClientBuilder {
        //        Sets the maximum number of times to retry sending the request to the API. (Default is 5)
        //
        //        Returns self to accommodate method chaining.
        
        self.maxRetries = maxRetries
        return self
    }
    
    func withMaxTimeout(maxTimeout:Int) -> ClientBuilder {
        //        The maximum time (in milliseconds) to wait for a connection, and also to wait for
        //        the response to be read. (Default is 10000)
        //
        //        Returns self to accommodate method chaining.
        
        self.maxTimeout = maxTimeout
        return self
    }
    
    func withSender(sender:SmartySender) -> ClientBuilder {
        //        Default is a series of nested senders.
        //
        //        Returns self to accommodate method chaining.
        
        self.sender = sender
        return self
    }
    
    func withSerializer(serializer:USZipCodeSerializer) -> ClientBuilder {
        //        Changes the Serializer from the default.
        //
        //        Returns self to accommodate method chaining.
        
        self.serializer = serializer
        return self
    }
    
    func withUrl(urlPrefix:String) -> ClientBuilder {
        //        This may be useful when using a local installation of the SmartyStreets APIs.
        //        Url is a string that defaults to the URL for the API corresponding to the Client object being built.
        //
        //        Returns self to accommodate method chaining.
        
        self.urlPrefix = urlPrefix
        return self
    }
    
    func withProxy(host:String, port:Int) -> ClientBuilder {
        //        Assigns a proxy through which to send all Lookups.
        
        //        Returns self to accommodate method chaining.
        
        self.proxy = [kCFNetworkProxiesHTTPEnable:1, kCFNetworkProxiesHTTPProxy: host, kCFNetworkProxiesHTTPPort: port]
        return self
    }
    
    func withDebug() -> ClientBuilder {
        //        Enables debug mode, which will print information about the HTTP request and response to the console.
        //
        //        Returns self to accommodate method chaining.
        
        self.debug = true
        return self
    }
    
    func buildUsStreetApiClient() -> USStreetClient {
        ensureURLPrefixNotNil(url: self.usStreetApiURL)
        let serializer = USStreetSerializer()
        return USStreetClient(sender: buildSender(), serializer: serializer)
    }
    
    func buildUsZIPCodeApiClient() -> USZipCodeClient {
        ensureURLPrefixNotNil(url: self.usZipCodeApiURL)
        let serializer = USZipCodeSerializer()
        return USZipCodeClient(sender:buildSender(), serializer: serializer)
    }
    
    func buildInternationalStreetApiClient() -> InternationalStreetClient {
        ensureURLPrefixNotNil(url: self.internationalStreetApiURL)
        let serializer = InternationalStreetSerializer()
        return InternationalStreetClient(sender:buildSender(), serializer: serializer)
    }
    
    func buildUSAutocompleteApiClient() -> USAutocompleteClient {
        ensureURLPrefixNotNil(url: self.usAutocompleteApiURL)
        let serializer = USAutocompleteSerializer()
        return USAutocompleteClient(sender: buildSender(), serializer: serializer)
    }
    
    func buildUsExtractApiClient() -> USExtractClient {
        ensureURLPrefixNotNil(url: self.usExtractApiURL)
        let serializer = USExtractSerializer()
        return USExtractClient(sender: buildSender(), serializer: serializer)
    }
    
    func buildSender() -> SmartySender {
        if let httpSender = self.sender {
            return httpSender
        }
        
        var httpSender:SmartySender = HttpSender(maxTimeout: self.maxTimeout, proxy: self.proxy, debug: self.debug)
        httpSender = StatusCodeSender(inner: httpSender)
        
        if self.maxRetries > 0 {
            httpSender = RetrySender(maxRetries: self.maxRetries, sleeper: SmartySleeper(), logger: SmartyLogger(), inner: httpSender)
        }
        
        if let httpSigner = self.signer {
            httpSender = SigningSender(signer: httpSigner, inner: httpSender)
        }
        
        httpSender = URLPrefixSender(urlPrefix: self.urlPrefix, inner: httpSender)
        
        return httpSender
    }
    
    func ensureURLPrefixNotNil(url:String) {
        if self.urlPrefix == nil {
            self.urlPrefix = url
        }
    }
}