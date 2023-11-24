function updateFormatNodeInfoDisplay(this)

    browser=iatbrowser.Browser;
    formatter=iatbrowser.FormatNodeInfoDisplay(browser.treePanel.currentNode);
    this.javaPeer.updateLabelText(formatter.toString());

end