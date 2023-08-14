classdef ReportLinkData
    properties(Constant)
        LINK_IMAGE='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH4AgTFSINa6JZlAAAAflJREFUKM+Nk89rknEcx9/PEGGPF9dJpjBRIWXgHHheiO0wFm7NVWZjeNOjnoctnXgrulhUI/8Dy2AtPLRTOY3FWC5PzrYH9Dma6PMICe9OyqT96Auvy/vzffN5f/h+vgJJ/M85PDxkq9UCALhcLqterz8RrjP3ej1ks1nKsjyiBwIBXGlWVRUvMhk2Gg2Mj4tYvruMSqWCH0dHmJi4gbGrukqSRFEU0e/3EYmE4Xa7hVAoJLTbbZye/oLmMqMsy9RqtXgYDFr1ev3JQN/7vMf27zZ0Ot2/ZlVVkcvlWK1WB1LN4/HA6/UKhUKBz58+AwD4lnyjsQczfj84AEgYJycBEg6HAx93dphKJNHpdDB3aw6P1tYEkARJdLtdpLa2GAmHGYvFKEkSB7X8u/ecdc5w1jnDzfjjoa4BAEVRkE6nKZ2dQRRFRKNRlPdLWEkv8abdjm/lMgBgxe/Hk2RCGEYlic14nPf8fobW11mv10kSwQcBWqfMQ1KJ5LDjAMiyzMWFBd5fXWWtVhu58PP4mPvF4sgI5xlrNptQFAVGoxEWi0UAgE+7u/Qt3uGHfB5TZjNMJpNw0XNqbDaboHYVFr98xZtXrwkAb7e3AQD9P30YDAbh0i0iiZeZDJ3T0yPENzYujHqe4W6XSyWWSyUAgN3hwO35eeG6n/YXeYFF5JfKRTIAAAAASUVORK5CYII='
    end
    properties
        Uuid;
        LinkStr;

        LinkIcon;

        HyperLink;

    end

    methods
        function this=ReportLinkData()
        end

        function out=get.HyperLink(this)
            linkCmd=sprintf('slreq.app.CallbackHandler.selectObjectByUuid(''%s'',''%s'')',this.Uuid,'standalone');
            linkUrl=rmiut.cmdToUrl(linkCmd);
            out=mlreportgen.dom.ExternalLink(...
            linkUrl,this.LinkStr);
        end

        function out=get.LinkIcon(this)
            out=mlreportgen.dom.Image(this.LINK_IMAGE);
        end



    end
end