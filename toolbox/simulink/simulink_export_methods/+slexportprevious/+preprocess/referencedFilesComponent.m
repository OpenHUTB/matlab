function referencedFilesComponent(obj)



    if isR2019bOrEarlier(obj.ver)

        obj.appendRule('<Object<Type|"Simulink:Editor:ReferencedFiles">:remove>');
    end

end
