function deleteModelUtil(modelUtil)


    if~isempty(modelUtil)
        modelUtil.delete();
    end
end
