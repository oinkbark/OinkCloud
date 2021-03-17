![OinkCloud Logo](logo.svg)

# OinkCloud
DISCLAIMER:
At the moment, this project is not designed to be directly implemented by others wishing to create their own cloud systems.
The primary purpose of this code is to demonstrate the possible usage of various technologies.

## The Values
The starting point of everything relates to values. Those in relation to this project can be located [here](values.md).

## The Story
In the right environment, a single individual can have power equal to that of teams and corporations. Automation plays an enormous role in creating that type of environment. Here is a small example of what needs to be automated on the backend: 

### Automated Features
- Operating system configuration
- Server cluster creation
- Service scaling
- Service discovery
- Secret management
- CDN caching
- SSL certificates
- DNS record modification
- Log and metric insights
- Separation of UI & API layers
- Builds, tests, & deployments
- *and more*...

### Manual Steps
Code is used to define nearly everything. However, that code must first be given access to accounts that only humans can create. A detailed list can be found [here](setup.md).

## The System
To explain how all of the chosen technologies interact together, the full "journey of a request" will be detailed. Most users of the web never know what actually happens each time they click their mouse or tap their screen, and will never care to. 

For those who do care:

1. **A Search:** 

> | Concepts  | Services         |
> | --------- | ---------------- |
> | SEO       | Google Analytics |
> | OS Config | Ansible & Packer | 
> | DNS, DDOS | Cloudflare       |
> - A query is entered into a search engine, such as Google. That provider keeps indexes of every webpage on the internet and tries to determine which one will best answer the search. If the UI sent to them contains the proper SEO elements (keywords, backlinks, and optimizations), a link to the page will be served near the top of the page for the user to view. 
> - It is then up to the user to decide which link to visit. If a site owner is lucky, the user will click on their link. That link uses DNS records to translate the name of the site (example.com) into an IP address of a preconfigured computer (123.456.789.0). Most requests sent to these addresses are made by humans, but malicious bots can be setup to spam requests in an attempt to overload this computer. Valid requests pass through a security filter and firewall.

2. **A Response:**

> | Concept           | Service          |
> | ----------------- | ---------------- |
> | Server Hosting    | DigitalOcean     |
> | Load Balancing    | NGINX            |
> | Encryption        | LetsEncrypt      |
> | Secret Management | HashiCorp Vault  |
> | Service Execution | HashiCorp Nomad  |
> | Service Discovery | HashiCorp Consul |
> -  The IP address sent back correlates to an allocation of physical resources such as RAM, CPU, and storage. These are commonly refered to as computers; often they are usually just portions of a larger machine and not dedicated devices. This allows an organization to have multiple smaller computers that serve specific jobs (horizontal scaling) instead of one monolith computer that does everything (vertical scaling). 
> - A load balancer is used to contain a list of these smaller computers and send out multiple requests for the data it needs before compiling it all into one single response for the user. That data is stored at rest behind secure authentication methods. To keep this data secure when it is being sent to the user, TLS certificates are used to encrypt the connection.

3. **Page Visuals** 

> | Concept       | Service      |
> | ------------- | ------------ |
> | Web Framework | Vue 3        |
> | CDN & Buckets | Google Cloud |
> - One of those computers is tasked with handling the first data sent back to the user: the stuff that they can actually see and interact with. This includes all of the page structure (HTML, CSS, and Javascript).
> - An external set of CDN computers serve the assets (images, icons, and videos). A CDN reduces the latency of receiving these large items, as they host multiple copies on many servers all around the globe and automatically know which one is closest to the user.

4. **Page Data**

> | Concept         | Service      |
> | --------------- | ------------ |
> | API             | GraphQL      |
> | Cache, Sessions | Redis        |
> | Database        | MongoDB      |
> | Logging         | Prometheus   |
> | Metrics         | Grafana      |
> - Once all the buttons and knobs appear in a user dashboard, something has to make them actually work. That something is data. Examples include user content, usage analytics, and product listings. These items are numerous and updated frequently. A cache, simliar to a CDN, is used to serve copies of these entries from databases, but can become stale if not refreshed enough. Metrics and logs are used to help prioritize popular data endpoints and ensure they are efficient and responsive.
> - To maximize network bandwidth and limit user data consumption, only a minimal amount of this vast data is sent initially. It is progressively fetched as it is needed to be viewed. If data needs to be manipulated (created/edited/deleted), authorization must first be granted. The most common way is to create a temporary browser session by entering in a username and password. From here the user has access to do what they want, which usually results in buttons being clicked and the journey of a request starting all over again.

## The Code
You will not find any code in the master branch. 

There are multiple branches; each one contains the code for the relevant abstraction.

## Credits
- OinkBark; Sole Creator

## License
[MIT](https://opensource.org/licenses/MIT)
