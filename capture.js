(function () {

  function getSelectionHtml() {
    var html = "";
    if (typeof window.getSelection != "undefined") {
      var sel = window.getSelection();
      if (sel.rangeCount) {
        var container = document.createElement("div");
        for (var i = 0, len = sel.rangeCount; i < len; ++i) {
            container.appendChild(sel.getRangeAt(i).cloneContents());
        }
        html = container.innerHTML;}
    } else if (typeof document.selection != "undefined") {
      if (document.selection.type == "Text") {
          html = document.selection.createRange().htmlText;
      }
    }
    var relToAbs = function (href) {
      var a = document.createElement("a");
      a.href = href;
      var abs = a.protocol + "//" + a.host + a.pathname + a.search + a.hash;
      a.remove();
      return abs;
    };
    var elementTypes = [['a', 'href'], ['img', 'src']];
    var div = document.createElement('div');
    div.innerHTML = html;
    elementTypes.map(function(elementType) {
      var elements = div.getElementsByTagName(elementType[0]);
      for (var i = 0; i < elements.length; i++) {
        elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));
      }
    });
    return div.innerHTML;
  }

  function replace_all(str, find, replace) {
    return str.replace(new RegExp(find, 'g'), replace);
  }

  function escapeIt(text) {
    return replace_all(replace_all(replace_all(encodeURIComponent(text), "[(]", escape("(")),
                                   "[)]", escape(")")),
                       "[']" ,escape("'"));
  }

  function  capture() {
    const uri = 'org-protocol:///capture-html-to-clipboard?url='+encodeURIComponent(location.href)+'&title='+escapeIt(document.title || "[untitled page]")+'&body='+encodeURIComponent(getSelectionHtml());
    window.console.log("Generated URI for org-protocol: ", uri);
    location.href = uri;
  }

  capture();
})();
