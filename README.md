<div align="center">
  <a href="https://hoppscotch.io">
    <img
      src="https://avatars.githubusercontent.com/u/56705483"
      alt="Hoppscotch"
      height="64"
    />
  </a>
  <h3>
    <b>
      Hoppscotch
    </b>
  </h3>
  <b>
    Open Source API Development Ecosystem
  </b>
  <p>

  </p>
  <p>
    <a href="https://hoppscotch.io">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="./packages/hoppscotch-common/public/images/banner-dark.png">
        <source media="(prefers-color-scheme: light)" srcset="./packages/hoppscotch-common/public/images/banner-light.png">
        <img alt="Hoppscotch" src="./packages/hoppscotch-common/public/images/banner-dark.png">
      </picture>
    </a>
  </p>
</div>

_We highly recommend you take a look at the [**Hoppscotch Documentation**](https://docs.hoppscotch.io) to learn more about the app._

## **Features**

### Core API Development
- **Multiple Protocol Support**: HTTP, WebSocket, Server-Sent Events, Socket.IO, MQTT, GraphQL
- **Request Methods**: Full HTTP method support (GET, POST, PUT, PATCH, DELETE, HEAD, CONNECT, OPTIONS, TRACE, and custom methods)
- **Authentication**: None, Basic, Bearer Token, OAuth 2.0, OIDC Access Token/PKCE, **FusionAuth SSO**
- **Pre-Request Scripts**: Execute JavaScript before sending requests
- **Post-Request Tests**: Automated testing after response receipt
- **Code Generation**: Generate request code snippets for 10+ languages and frameworks

### Collaboration & Teams
- **Workspaces**: Organize personal and team collections into separate workspaces
- **Workspace Search**: Quick filtering when managing 5+ team workspaces
- **User Groups**: Organization-level user group management for streamlined team access control
- **Teams**: Create unlimited teams with role-based access control (OWNER, EDITOR, VIEWER)
- **Shared Collections**: Collaborate on API collections with version control
- **Real-time Sync**: Changes synchronized across devices and team members

### Enhanced Authentication
- **FusionAuth Integration**: Enterprise-grade authentication with MFA/2FA support
- **SSO Logout**: Centralized session management across all authentication providers
- **Multi-Provider Support**: GitHub, Google, Microsoft, Email, and FusionAuth
- **Advanced Security**: Password policies, brute-force protection, leaked password detection

### User Experience
- **Lightweight UI**: Minimalistic design for optimal performance
- **Theming**: Customizable color schemes (System, Light, Dark, Black) with 8 accent colors
- **PWA Support**: Install as a Progressive Web App with offline support
- **Keyboard Shortcuts**: Optimized workflow efficiency
- **i18n**: Multi-language support

### Data Management
- **Collections**: Unlimited collections, folders, and requests with nested organization
- **Environments**: Create and manage environment variables across projects
- **History**: Request history synced with cloud/local session storage
- **Import/Export**: Support for cURL, OpenAPI, and other formats
- **Bulk Edit**: Edit key-value pairs efficiently

### Enterprise Features
- **Admin Dashboard**: Comprehensive user, team, and workspace management
- **User Groups**: Role-based group access control across multiple teams
- **Audit Logging**: Detailed activity tracking for compliance
- **SSO Integration**: FusionAuth and other enterprise identity providers
- **Advanced Security**: Enhanced authentication and authorization controls

**For a complete list of features, please read our [documentation](https://docs.hoppscotch.io).**

## **Demo**

- Web : [hoppscotch.io](https://hoppscotch.io)
- Windows/Linux/macOS : [Desktop Apps](https://docs.hoppscotch.io/documentation/clients/desktop#download-hoppscotch-desktop-app)

## **Getting Started**

### Quick Start
1. Navigate to [hoppscotch.io](https://hoppscotch.io)
2. Enter your API endpoint in the URL field
3. Select HTTP method and configure request parameters
4. Click "Send" to execute the request
5. View and analyze the response

### Self-Hosting
Follow our [self-hosting documentation](https://docs.hoppscotch.io/documentation/self-host/getting-started) to deploy Hoppscotch on your infrastructure.

#### Enterprise Features Setup
For FusionAuth integration and User Groups features, refer to:
- [FusionAuth Setup Guide](https://docs.hoppscotch.io/documentation/self-host/fusionauth)
- [User Groups Configuration](https://docs.hoppscotch.io/documentation/self-host/user-groups)

## **Development**

Follow our [development environment setup guide](https://docs.hoppscotch.io/documentation/self-host/getting-started) to get started with local development.

## **Contributing**

Please contribute using [GitHub Flow](https://guides.github.com/introduction/flow). Create a branch, add commits, and [open a pull request](https://github.com/hoppscotch/hoppscotch/compare).

Please read [`CONTRIBUTING`](CONTRIBUTING.md) for details on our [`CODE OF CONDUCT`](CODE_OF_CONDUCT.md), and the process for submitting pull requests.

## **Add-ons**

Official add-ons for Hoppscotch:

- **[Hoppscotch CLI](https://github.com/hoppscotch/hoppscotch/tree/main/packages/hoppscotch-cli)** - Command-line interface for automated API testing and CI/CD integration
- **[Proxy](https://github.com/hoppscotch/proxyscotch)** - Simple proxy server for CORS issue resolution
- **[Browser Extensions](https://github.com/hoppscotch/hoppscotch-extension)** - Enhanced browser integration

  [![Firefox](https://raw.github.com/alrra/browser-logos/master/src/firefox/firefox_16x16.png) **Firefox**](https://addons.mozilla.org/en-US/firefox/addon/hoppscotch) &nbsp;|&nbsp; [![Chrome](https://raw.github.com/alrra/browser-logos/master/src/chrome/chrome_16x16.png) **Chrome**](https://chrome.google.com/webstore/detail/hoppscotch-extension-for-c/amknoiejhlmhancpahfcfcfhllgkpbld)

_Add-ons are developed and maintained under **[Hoppscotch Organization](https://github.com/hoppscotch)**._


## **Changelog**

See the [`CHANGELOG`](CHANGELOG.md) file for details.

## **License**

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT) — see the [`LICENSE`](LICENSE) file for details.
