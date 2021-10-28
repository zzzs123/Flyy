//
//  AppDelegate.swift
//  Flyy
//
//  Created by sillyb on 2021/10/27.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let menu = NSMenu(title: "Menu")

    let statusItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    let toggleItem = NSMenuItem(title: "load core", action: nil, keyEquivalent: "")


    lazy var pacItem: NSMenuItem = {
        let item = NSMenuItem(title: "Pac mode", action: nil, keyEquivalent: "")
        let editPacItem = NSMenuItem(title: "Edit Pac File", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "")
        submenu.items = [NSMenuItem.separator(),editPacItem,]
        item.submenu = submenu
        return item
    }()
    let globalItem = NSMenuItem(title: "Global mode", action: nil, keyEquivalent: "")
    let directItem = NSMenuItem(title: "Direct mode", action: nil, keyEquivalent: "")

    lazy var serverItem: NSMenuItem = {
        let item = NSMenuItem(title: "Server", action: nil, keyEquivalent: "")
        let useAllItem = NSMenuItem(title: "Use All", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "")
        submenu.items = [NSMenuItem.separator(),useAllItem]
        item.submenu = submenu
        return item
    }()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if installProxyConf(force: false) == false {
            NSApp.terminate(nil)
        }
        
        menu.items = [statusItem,
                      toggleItem,
                      NSMenuItem.separator(),
                      pacItem,
                      globalItem,
                      directItem,
                      NSMenuItem.separator(),
                      serverItem,
                      ]

        statusBarItem.menu = menu

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    
    func installProxyConf(force: Bool) -> Bool {
        let fileExists = FileManager.default.fileExists(atPath: proxyConfPath)
        //TODO: need verify version
        if !force && fileExists && isProxyConfVersionOK {
            return true
        }
        
        let alert = NSAlert()
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Quit")
        alert.messageText = "Flyy needs to install a tool to /Library/Application Support/Flyy/ with administrator privileges to set system proxy quickly.\nOtherwise you need to type in the administrator password every time you change system proxy through Flyy."
        if alert.runModal() == .alertFirstButtonReturn {
            guard let sh = Bundle.main.path(forResource: "install_helper", ofType: "sh"), let scriptObject = NSAppleScript(source: "do shell script \"sh \(sh)\" with administrator privileges") else {
                return false
            }
            var errorInfo: NSDictionary?
            let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&errorInfo)
            print(output.stringValue ?? "")
            if (errorInfo != nil) {
                print("do shell script error: \(String(describing: errorInfo))")
                return false
            }
            return true

        }
        return false
    }

    private let flyyPathComponent = "/Flyy"

    var installPath: String {
        // install for user
//        guard let supportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first else {
//            return NSHomeDirectory() + "/Library/Application Support" + flyyPathComponent
//        }
        
        // install for all
        guard let supportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .systemDomainMask, true).first else {
            return NSHomeDirectory() + "/Library/Application Support" + flyyPathComponent
        }
        return supportDir + flyyPathComponent
    }
    
    var v2rayPath: String {
        let path = installPath + "/v2ray-core/v2ray"
        let fileExists = FileManager.default.fileExists(atPath: path)
        if fileExists {
            //TODO: check NSFilePosixPermissions
            return path
        }
        return Bundle.main.path(forResource: "v2ray", ofType: nil, inDirectory: "v2ray-core")!
    }

    var proxyConfPath: String {
        let path = installPath + "/proxy_conf"
        return path
    }

    var jsonPath: String? {
        let path = installPath + "/config.json"
        let fileExists = FileManager.default.fileExists(atPath: path)
        if fileExists {
            return path
        }
        return nil
    }
    
    var isProxyConfVersionOK: Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: self.proxyConfPath)
        process.arguments = ["-v"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        guard let data = try? pipe.fileHandleForReading.readToEnd() else {
            return false
        }
        
        let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if str != kProxyConfVersion {
            return false
        }
        return true
    }
}

