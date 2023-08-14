classdef (ConstructOnLoad = true, Sealed = true) EnumTypeDefinition < Simulink.dd.EnumTypeSpec
    % A handle class that specifies the definition of an enumerated type.
    % That is, it is not a type itself but is used by the dictionary
    % infrastructure to create an MCOS enum class from the dictionary
    % specification

    %   Copyright 2012-2020 The MathWorks, Inc.
    
    methods
        function disp(obj)
            disp('   Simulink.data.dictionary.EnumTypeDefinition');
            for e = 1:length(obj.Enumerals)
                disp(['      ' obj.Enumerals(e).Name]);
            end
        end % disp
    end % methods
    
    methods (Static, Hidden)
      function enumTypeDefinition = convertFromEnumTypeSpec (enumTypeSpec)
	     enumTypeDefinition = Simulink.data.dictionary.EnumTypeDefinition;
		 % copy properties from Simulink.dd.EnumTypeSpec object
 
        % populate list of enumerals
        assert(enumTypeSpec.numEnumerals > 0);
        [enumName, enumValue, enumDescription] = enumTypeSpec.enumeralAt(1);
        enumTypeDefinition.setEnumName(1, enumName);
        enumTypeDefinition.setEnumValue(1, enumValue);
        enumTypeDefinition.setEnumDescription(1, enumDescription);
        for enumNum = 2:enumTypeSpec.numEnumerals
            [enumName, enumValue, enumDescription] = enumTypeSpec.enumeralAt(enumNum);
            enumTypeDefinition.appendEnumeral(enumName, enumValue, enumDescription);
        end

        % set the rest of the properties
        enumTypeDefinition.Description  = enumTypeSpec.Description;
        enumTypeDefinition.DataScope    = enumTypeSpec.DataScope;
        enumTypeDefinition.HeaderFile   = enumTypeSpec.HeaderFile;
        enumTypeDefinition.DefaultValue = enumTypeSpec.DefaultValue;
        enumTypeDefinition.StorageType  = enumTypeSpec.StorageType;
        enumTypeDefinition.AddClassNameToEnumNames = ...
                              enumTypeSpec.AddClassNameToEnumNames;
      end
    end % static methods

end % classdef
