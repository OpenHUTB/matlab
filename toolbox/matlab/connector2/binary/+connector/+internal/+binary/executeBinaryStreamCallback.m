function success=executeBinaryStreamCallback(name,message)

    weakRef=connector.internal.binary.BinaryStream.fetch(name);
    if~isempty(weakRef)&&~isDestroyed(weakRef)
        stream=weakRef.get;
        stream.doCallback(message);
    end
    success=true;
end