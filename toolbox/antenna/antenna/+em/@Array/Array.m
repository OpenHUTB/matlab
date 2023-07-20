classdef Array < em.EmStructures &                                      ...
                 em.MeshGeometry &                                      ...
                 em.MeshGeometryAnalysis&                               ...
                 em.PortAnalysis &                                      ...
                 em.SharedPortAnalysis &                                ...
                 em.SurfaceAnalysis &                                   ...
                 em.FieldAnalysisWithFeed &                             ...
                 em.FieldAnalysisWithWave &                             ...
                 em.ArrayAnalysis &                                     ...
                 em.DesignAnalysis &                                    ...
                 em.OptimizationAnalysis
    %ARRAY Abstract superclass for all the array classes in Antenna Toolbox
    % Captures common properties and associated methods
    
    %   Copyright 2014-2022 The MathWorks, Inc.
    
    properties(Dependent,GetAccess=public,SetAccess=protected)
        ArraySize
        ElementSize
    end
    
    properties (Dependent,SetObservable)
        % Amplitude weighting for the source of each element in array
        AmplitudeTaper
        % Phase shift applied to the source of each element in array
        PhaseShift
    end
    
    properties(Dependent,GetAccess=public,SetAccess=protected,SetObservable)
        FeedLocation
    end
    
    properties(GetAccess=public,SetAccess=protected)
        TranslationVector
    end
    
    properties(Access=protected)
        DefaultFeedLocation        
        ArrayElementModeUnlock
        FeedLocationErrorFlag
        FeedLocationErrorMessage 
    end
    
    properties(Access=protected)
        privateSubstrate = dielectric('Name','Air')
    end
    
    properties(Dependent,GetAccess=public,SetAccess=protected)
        TotalArraySpacing
    end
     
    properties(Access=protected)
        privateArrayStruct = struct('ElementSize',[],                   ...
                                    'ArraySize',[],                     ...
                                    'AmplitudeTaper',[],                ...
                                    'PhaseShift',[],                    ...
                                    'FeedLocation',[],                  ...
                                    'TotalArraySpacing',[])    
    end
    
    methods (Access = protected)            % Constructor
        function obj = Array(aArraySize,aAmplitudeTaper,aPhaseShift,    ...
                aTilt,aTiltAxis,aElementSize)
            if nargin>5
                obj.ElementSize         = aElementSize;
                obj.ArraySize           = aArraySize;
                obj.AmplitudeTaper      = aAmplitudeTaper;
                obj.PhaseShift          = aPhaseShift;
                obj.Tilt                = aTilt;
                obj.TiltAxis            = aTiltAxis;
            else
                obj.ArraySize           = aArraySize;
                obj.AmplitudeTaper      = aAmplitudeTaper;
                obj.PhaseShift          = aPhaseShift;
                obj.Tilt                = aTilt;
                obj.TiltAxis            = aTiltAxis;
            end
            obj.privateSubstrate = dielectric('Air');
        end
    end
    
    methods
        
       function set.ElementSize(obj,propVal)
            obj.privateArrayStruct.ElementSize = propVal;
        end
        
        function propVal = get.ElementSize(obj)
            propVal = obj.privateArrayStruct.ElementSize;
        end

        function set.ArraySize(obj,propVal)
%             obj.ArraySize = propVal;
            obj.privateArrayStruct.ArraySize = propVal;
            setTotalArrayElems(obj, prod(propVal));
        end
        
        function propVal = get.ArraySize(obj)
           propVal = obj.privateArrayStruct.ArraySize; 
        end
        
        function set.AmplitudeTaper(obj,propVal)
            
            if ~isscalar(obj.ArraySize)
                numelements = prod(obj.ArraySize);
            elseif isempty(obj.ElementSize)
                numelements = obj.ArraySize;
            else

                numelements = obj.ElementSize;                
            end
            
            if isscalar(propVal)
                validateattributes(propVal,{'numeric'},{'vector','nonempty',...
                    'real','finite','nonnan', 'nonnegative'},               ...
                    class(obj),'AmplitudeTaper');
            else
                validateattributes(propVal,{'numeric'},{'vector','nonempty',...
                    'real','finite','nonnan', 'nonnegative',                ...
                    'numel',numelements}, class(obj),'AmplitudeTaper');
            end
            
            if ~any(propVal)
                error(message('antenna:antennaerrors:AllZeroAmplitudetaper'));
            end
            
            if ~isequal(obj.AmplitudeTaper,propVal) %isPropertyChanged(obj,obj.AmplitudeTaper,propVal)
                obj.privateArrayStruct.AmplitudeTaper = propVal;
                obj.MesherStruct.HasTaperChanged = 1;
                checkAmplitudeTaper(obj,numelements);
                objParent = getParent(obj);
                if ~isempty(objParent)
                    objParent.MesherStruct.HasTaperChanged = 1;
                end 
            end
        end
        
        function propVal = get.AmplitudeTaper(obj)
            propVal = obj.privateArrayStruct.AmplitudeTaper;            
        end
              
        function set.PhaseShift(obj,propVal)
            
            if ~isscalar(obj.ArraySize)
                numelements = prod(obj.ArraySize);
            elseif isempty(obj.ElementSize)
                numelements = obj.ArraySize;
            else
                numelements = obj.ElementSize;
            end
            
            if isscalar(propVal)
                validateattributes(propVal,{'numeric'},{'vector','nonempty',...
                    'real','finite','nonnan'},               ...
                    class(obj),'PhaseShift');
            else
                validateattributes(propVal,{'numeric'},{'vector',       ...
                    'nonempty','real','finite','nonnan',                ...
                    'numel',numelements}, class(obj),'PhaseShift');
            end
            
            if ~isequal(obj.PhaseShift, propVal) %isPropertyChanged(obj,obj.PhaseShift,propVal)
                obj.privateArrayStruct.PhaseShift = propVal;
                obj.MesherStruct.HasTaperChanged = 1;
                checkPhaseShift(obj,numelements);
                objParent = getParent(obj);
                if ~isempty(objParent)
                    objParent.MesherStruct.HasTaperChanged = 1;
                end                    
            end
        end
        
        function propVal = get.PhaseShift(obj)
            propVal = obj.privateArrayStruct.PhaseShift;
        end
        
        
        function set.FeedLocation(obj,propVal)
            validateattributes(propVal,{'numeric'},{'finite',...
                'real','nonnan'});
            obj.privateArrayStruct.FeedLocation = propVal;
        end
        
        function propVal = get.FeedLocation(obj)
            if obj.FeedLocationErrorFlag
                error(obj.FeedLocationErrorMessage);
            else
                propVal = calculateFeedLocation(obj);
                obj.privateArrayStruct.FeedLocation = propVal;
            end
        end
        
        function set.FeedLocationErrorFlag(obj,propVal)
           obj.FeedLocationErrorFlag = propVal;
        end
        
        function set.FeedLocationErrorMessage(obj,propVal)
           obj.FeedLocationErrorMessage = propVal; 
        end
        
        function set.DefaultFeedLocation(obj,propVal)
            obj.DefaultFeedLocation = propVal;
        end
                
        function set.TranslationVector(obj,propVal)
            obj.TranslationVector = propVal;
        end
        
        function set.ArrayElementModeUnlock(obj,propVal)
           obj.ArrayElementModeUnlock = propVal; 
        end
  
        function set.TotalArraySpacing(obj,propVal)
           obj.privateArrayStruct.TotalArraySpacing = propVal; 
        end
        
        function propVal = get.TotalArraySpacing(obj)
            propVal = obj.privateArrayStruct.TotalArraySpacing;             % Returns scalar for linear and 2 element vector for rectangular
        end
    end
    
    % -------------Analysis methods------------------%
%     methods
%         layout(obj);
%         varargout = impedance(obj,freq, ElemNumber);
%         varargout = returnLoss(obj,freq, Z0, ElemNumber);
%         S = sparameters(obj, freq, ZL);
%     end
    
    methods (Hidden)
        function [edgeLength,growthRate] = calculateWireMeshParams(obj,lambda) %#ok<INUSL>
            s   = lambda/8;
            edgeLength = s;
            growthRate = 2.0;
        end
        
        function wireStackOut = wire(obj)
            [isConv, messCell] = obj.isConvertable2Wire;
            if isConv
                wireStackOut = wireStack(obj);
                wireStackOut.Name = obj.wireName('Singular');
            else
                error(message(messCell{:}));
            end
        end
        
        function value = isRadiatorLossy(obj)
           if isa(obj,'conformalArray')
                checkIfElementHasLossySubstrate(obj);
           end
           value = ~isequal(obj.privateSubstrate.LossTangent,0); 
           if isa(obj, 'customArrayMesh')
               return;
           end
           if ~value
               createGeometry(obj);
               if ~isinf(obj.MesherStruct.conductivity) ||                  ...
                       ~isequal(obj.MesherStruct.thickness, 0)
                   value = 1;
               end

               if ~value
                   createGeometry(obj);
                   if isfield(obj.MesherStruct,'Load')
                       if ~isempty(obj.MesherStruct.Load)
%                            if iscell(obj.MesherStruct.Load.Impedance)
                               ZL=real(cell2mat(obj.MesherStruct.Load.Impedance));
%                            else
%                                ZL=real(obj.MesherStruct.Load.Impedance);
%                            end                          
                           if any(ZL>0) 
                               value=1;
                           end
                       end
                   end

               end

               if isa(obj.Element, 'em.Array') || isa(obj.Element, 'dipoleCrossed')
                   obj.MesherStruct.HasStructureChanged = 0;
                   if isscalar(obj.Element)
                       obj.Element.MesherStruct.HasStructureChanged = 0;
                   end
               end               
           end
        end             
    end
    
    methods(Abstract,Access=protected)
        feedloc     = calculateFeedLocation(obj);
        spacing     = calculateArraySpacing(obj);
    end
    
    methods (Access=protected)   %---- Check properties              
        v           = calculateTranslateVector(obj);
%         gndPlaneDim = checkGndPlane(obj);
        checkReference(obj,propVal);
        checkElementPosition(obj,propVal);
        checkHeterogeneousElementForRectangular(obj,propVal);
        checkHeterogeneousElementForLinear(obj,propVal);
        checkHeterogeneousElementForConformal(obj,propVal);
        checkProbeFeedStatusForForHeterogeneousElement(obj,propVal);
        checkSubstrateForHetereogeneousElement(obj,propVal);
        checkConformalArrayParameters(obj);
        checkAmplitudeTaper(obj,numelements);        
        checkPhaseShift(obj,numelements);
        checkIfElementHasInfGndPlane(obj,element);
        checkMeshForLargeStructure(obj, Mesh);
        setElementForConformalArray(obj,propVal);  
        setElementAsCellArray(obj,propVal,excludeList);
        setElementAsHandleArray(obj,propVal,excludeList);
        setElementAsScalarHandle(obj,propVal,excludeList1,excludeList2);
        setGroundPlaneFlags(obj,propVal);
        makeConformalArray(obj);    
        [p_element,t_element,T_element,array_dielectric] = makeConformalArrayMesh(obj);
        tempElement = makeTemporaryElementCacheForConformal(obj,n);
        checkIfElementHasLossySubstrate(obj);
        tf = isArrayOnDielectricSubstrate(obj);
        resetPrivateSubstrate(obj);
        C = coupling(obj, freq, ZL);
        refreshFeedLocation(obj);
    end
        
    methods(Static=true,Access=protected)
        [BorderVertices,Polygons,DoNotPlot,BoundaryEdges] =             ...
            makeArrayGeometry(geom,translateVector,offset, InfGP);
        [BorderVertices,Polygons,DoNotPlot,BoundaryEdges] =            ...
    makeArrayGeometryForConformalArray(geom,translateVector,offset, InfGP,flag);

        sub_array=makeSubArray(obj);
        
        feedloc = calculatefeedloc(asize ,drow, dcol, startpoint,lattice,skew,spacing);  
        
        % Plot the active impedance and return loss for the array
        plotactivedata(data, freq) % plotactivedata       
        
        % Plot the impedance data
        plotdatacomplex(freq, data, U, val, legstr, haxes, numelems)% of plotdatacomplex
        
        % Plot the return loss data
        plotdatareal(freq, data, U, val, legstr, haxes, numelems)% of plotdatareal
        
        cv = colorvector(num)% of colorvector
        
    end
    
    methods(Access={?planeWaveExcitation,?em.WireStructures,?em.Array, ...
            ?em.Antenna})
        function [val, messCell] = isConvertable2Wire(obj)
            val = false;
            messCell = {'antenna:antennaerrors:NotConvertableToWire',   ...
                class(obj)};
        end
        
    end
    
    methods(Access={?planeWaveExcitation,?em.WireStructures,?em.Array})
        function name = wireName(obj, nameType)
            nameOrig = 'Array';
            ElemName = lower(obj.Element(1).wireName('Plural'));
            name = [upper(nameOrig(1)) nameOrig(2:end)];
            if nargin > 1 && strcmpi(nameType,'Plural')
                name = [name 's of ' ElemName];
            else
                name = [name ' of ' ElemName];
            end
        end
        
    end
    
    methods(Hidden)
        function rObj = superLoadArray(obj,s)
            obj = superLoadMeshGeometry(obj,s);
            obj = superLoadEmStructures(obj,s);
            obj.ArraySize            = s.ArraySize;
            obj.AmplitudeTaper       = s.AmplitudeTaper;
            obj.PhaseShift           = s.PhaseShift;
            if (s.MesherStruct.Version >= 2.0)
                obj.privateSubstrate     = s.privateSubstrate;
                obj.privateArrayStruct   = s.privateArrayStruct;
            end
            rObj = obj;
        end
    end
    
end % of Array
