function checkValidEntry(obj)




    if~obj.isvalid||coder.dictionary.internal.isCoderDictionaryRemoved(obj)
        DAStudio.error('SimulinkCoderApp:data:InvalidEntry');
    end
end
