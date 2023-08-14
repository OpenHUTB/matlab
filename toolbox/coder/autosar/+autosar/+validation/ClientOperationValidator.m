classdef ClientOperationValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(self,hModel)
            self.verifyShortNames(hModel);
            self.verifyQualifiedNames(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyShortNames(hModel)

            clientPortBlks=arblk.findAUTOSARClientBlks(getfullname(hModel));

            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');



            testStrs={};
            for ii=1:numel(clientPortBlks)
                obj=get_param(clientPortBlks{ii},'object');
                fcn=arblk.parseOperationPrototype(obj.operationPrototype,maxShortNameLength);
                testStrs=[testStrs;...
                cellstr(obj.portName);...
                cellstr(fcn.name);...
                ];%#ok<AGROW>
            end




            idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier(testStrs,'shortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                msg=idcheckmessage;
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end

        end

        function verifyQualifiedNames(hModel)

            clientPortBlks=arblk.findAUTOSARClientBlks(getfullname(hModel));
            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');


            testStrs={};
            for ii=1:length(clientPortBlks)
                testStrs=[testStrs;...
                cellstr(get_param(clientPortBlks(ii),'interfacePath'));...
                ];%#ok<AGROW>
            end


            idcheckmessage=autosar.validation.AutosarUtils.isValidIdentifier(testStrs,'absPathShortName',maxShortNameLength);
            if~isempty(idcheckmessage)
                msg=idcheckmessage;
                autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
            end


        end

    end

end


