classdef simscapeBlockDataset<handle



    properties(SetAccess=public,GetAccess=public)
name
description
    end

    properties(SetAccess=private,GetAccess=public)
characteristicData
tabulatedData
parameters
    end

    methods(Access=public)
        function theSimscapeBlockDataset=simscapeBlockDataset(varargin)
            if nargin>=1
                theSimscapeBlockDataset.name=varargin{1};
            end
            if nargin>=2
                theSimscapeBlockDataset.description=varargin{2};
            end
            if nargin>2
                warning(getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:warning_IgnoringExtraConstructorArgs')));
            end

            theSimscapeBlockDataset.tabulatedData=simscapeTabulatedData.empty;
            theSimscapeBlockDataset.characteristicData=simscapeCharacteristic.empty;
            theSimscapeBlockDataset.parameters=simscapeBlockParameterSet;
        end

        function addCharacteristic(theSimscapeBlockDataset,characteristic)
            if~isa(characteristic,'simscapeCharacteristic')
                pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_CharacteristicMustBeASimscapeCharacteristic')));
            end
            theSimscapeBlockDataset.characteristicData(end+1)=characteristic;
        end

        function deleteCharacteristic(theSimscapeBlockDataset,index)
            if index>length(theSimscapeBlockDataset.characteristicData)
                pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_CharacteristicWithTheEvaluatedIndex')));
            end
            theSimscapeBlockDataset.characteristicData(index)=[];
        end

        function deleteCharacteristicCurve(theSimscapeBlockDataset,characteristicIndex,curveIndex)
            if characteristicIndex>length(theSimscapeBlockDataset.characteristicData)
                pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_CharacteristicWithTheEvaluatedIndex')));
            end
            theSimscapeBlockDataset.characteristicData(characteristicIndex).deleteCurve(curveIndex);
        end

        function addTabulatedData(theSimscapeBlockDataset,data)
            if~isa(data,'simscapeTabulatedData')
                pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_DataMustBeASimscapeTabulatedData')));
            end
            theSimscapeBlockDataset.tabulatedData(end+1)=data;
        end

        function addParameterSet(theSimscapeBlockDataset,pSet)
            if~isa(pSet,'simscapeBlockParameterSet')
                pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_ParametersMustBeASimscapeBlockParameterSet')));
            end
            theSimscapeBlockDataset.parameters(end+1)=pSet;
        end

        function value=getTabulatedDataFromName(theSimscapeBlockDataset,aString)
            if~ischar(aString)&&~isstring(aString)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_PropertyName')));
            end
            value='';
            for ii=1:length(theSimscapeBlockDataset.tabulatedData)
                if strcmp(aString,theSimscapeBlockDataset.tabulatedData(ii).name)
                    value=theSimscapeBlockDataset.tabulatedData(ii).value;
                    break;
                end
            end
        end

        function value=getTabulatedDataFromSymbol(theSimscapeBlockDataset,aString)
            if~ischar(aString)&&~isstring(aString)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_PropertyName')));
            end
            value='';
            for ii=1:length(theSimscapeBlockDataset.tabulatedData)
                if strcmp(aString,theSimscapeBlockDataset.tabulatedData(ii).symbol)
                    value=theSimscapeBlockDataset.tabulatedData(ii).value;
                    break;
                end
            end
        end
    end

    methods
        function set.name(theSimscapeBlockDataset,aString)
            if~ischar(aString)&&~isstring(aString)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_PropertyName')));
            end
            theSimscapeBlockDataset.name=char(aString);
        end

        function set.description(theSimscapeBlockDataset,aString)
            if~ischar(aString)&&~isstring(aString)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockDataset:error_PropertyDescription')));
            end
            theSimscapeBlockDataset.description=char(aString);
        end
    end
end