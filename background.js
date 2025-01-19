chrome.browserAction.onClicked.addListener(function (tab) {
  chrome.tabs.executeScript({file: "capture.js"});
});

chrome.commands.onCommand.addListener(function (command) {
    if (command === "capture_org_to_clipboard") {
        chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
            chrome.tabs.executeScript(tabs[0].id, { file: "capture.js" });
        });
    }
});
