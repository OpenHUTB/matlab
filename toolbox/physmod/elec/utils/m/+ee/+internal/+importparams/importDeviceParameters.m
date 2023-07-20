function importDeviceParameters(varargin)



















    try

        narginchk(3,7);


        parserObject=inputParser;
        parserObject.FunctionName=mfilename;


        parserObject.addRequired('FileName');
        parserObject.addRequired('Format');

        parserObject.addRequired('BlockPath');


        parserObject.addParameter('OutputFile','',@(s)endsWith(s,'.xml'));

        verboseValidationFcn=@(x)validateattributes(x,{'logical'},{'scalar'});
        parserObject.addParameter('Verbose',false,verboseValidationFcn);


        parserObject.parse(varargin{:});
        fileName=parserObject.Results.FileName;
        mappingFormat=parserObject.Results.Format;
        block=parserObject.Results.BlockPath;
        verboseMode=parserObject.Results.Verbose;


        rootPackage=meta.package.fromName('ee.internal.importparams');
        subPackageNames=extractAfter({rootPackage.PackageList.Name},[rootPackage.Name,'.']);
        mappingFormat=validatestring(mappingFormat,subPackageNames,parserObject.FunctionName,'Format');


        theMappingName=ee.internal.importparams.(mappingFormat).Format.getMappingClassFromXml(fileName);


        try
            mappingObject=ee.internal.importparams.(mappingFormat).(theMappingName)(fileName,block,verboseMode);
        catch theException
            switch theException.identifier
            case{'physmod:ee:importparams:MappingBlockXml:InvalidFileFormat',...
                'physmod:ee:importparams:MappingBlockXml:InvalidBlockPath',...
                'physmod:ee:importparams:MappingBlockXml:InvalidReferenceBlock',...
                'physmod:ee:importparams:MappingBlockXml:OnlySimscapeBlocks'}
                throw(theException)
            otherwise

                pm_error('physmod:ee:importparams:MappingBlockXml:MappingNotFound',theMappingName)
            end
        end


        mappingObject.applyMapping();


        noAction=true;

        if~isempty(block)
            noAction=false;
            mappingObject.updateBlockParameters();
        end

        if nargin>3&&~any(strcmp(parserObject.UsingDefaults,'OutputFile'))
            noAction=false;
            outputFile=parserObject.Results.OutputFile;
            mappingObject.writeTargetXml(outputFile);
        end

        if noAction



            pm_error('physmod:ee:importparams:MappingBlockXml:NoBlockProvided');
        end
    catch ME

        throwAsCaller(ME);
    end


end
