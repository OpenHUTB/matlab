classdef Client<handle
    properties(Access=private,Transient=true)
PIServer
    end

    properties(GetAccess=public,SetAccess=private,Transient=true)
        ServerName string
        Domain string
    end

    properties(Hidden,Constant,Transient=true)

        RecordedValuesExample=("getRecordedValues(client, tagName)"+newline+...
        "getRecordedValues(client, tagName, From = datetime, To = datetime)")
        InterpolatedValuesExample=("getInterpolatedValues(client, tagName)"+newline+...
        "getInterpolatedValues(client, tagName, From = datetime, To = datetime)"+newline+...
        "getInterpolatedValues(client, tagName, From = datetime, To = datetime, Every = duration)")
        ReadExample=("read(client, tagName)"+newline+...
        "read(client, tagName, Earliest = logical)"+newline+...
        "read(client, tagName, DateRange = [datetime, datetime])"+newline+...
        "read(client, tagName, DateRange = [datetime, datetime], Interval = duration)")
        TagsExample=("tags(client)"+newline+...
        "tags(client, Name = tagName)")
        StartTimeOfTagsExample=("getStartTimeOfTags(client, tagName)")
        FindTagsExample=("findTags(client, tagName)")
    end


    methods(Access=public)

        function piclientObj=Client(varargin)
            icomm.pi.internal.checkLicense();

            try
                narginchk(1,7);
            catch ME
                throwAsCaller(ME);
            end

            p=inputParser();
            p.KeepUnmatched=true;
            p.addRequired("Servername",@(x)validateattributes(x,{'string','char'},{'scalartext'}));
            p.addParameter("Username","",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter("Password","",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.addParameter("Domain","",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            p.parse(varargin{:});
            parsedInputs=p.Results;

            usingDefaults=convertCharsToStrings(p.UsingDefaults);
            serverName=parsedInputs.Servername;

            piclientObj.addAssembly();
            PIServers=OSIsoft.AF.PI.PIServers;

            foundServer=false;
            for serverIndex=0:PIServers.Count-1
                server=PIServers.Item(serverIndex);

                numAlias=server.AliasNames.Count;
                names=strings(1,numAlias+1);
                names(end)=server.Name;
                for aliasIndex=1:numAlias
                    names(aliasIndex)=server.AliasNames.Item(aliasIndex-1);
                end

                if any(strcmp(serverName,names))
                    piclientObj.PIServer=server;
                    piclientObj.ServerName=serverName;
                    foundServer=true;
                    break
                end
            end


            if~foundServer
                error(message('icomm_osisoftpi:messages:PIServerNotFound',serverName));
            end

            piclientObj.PIServer.Disconnect();

            if~any("Username"==usingDefaults)

                if any("Password"==usingDefaults)

                    error(message('icomm_osisoftpi:messages:PasswordRequired'));
                end
                if~any("Domain"==usingDefaults)

                    credentials=System.Net.NetworkCredential(parsedInputs.Username,parsedInputs.Password,parsedInputs.Domain);
                else

                    credentials=System.Net.NetworkCredential(parsedInputs.Username,parsedInputs.Password);
                end

                try
                    piclientObj.PIServer.Connect(credentials,OSIsoft.AF.PI.PIAuthenticationMode.WindowsAuthentication);
                catch
                    error(message('icomm_osisoftpi:messages:CredentialsNotAccepted'));
                end
            elseif~any("Password"==usingDefaults)

                error(message('icomm_osisoftpi:messages:UsernameRequired'));
            else

                try
                    piclientObj.PIServer.Connect();
                catch
                    error(message('icomm_osisoftpi:messages:ConnectionUnsuccessful'));
                end
            end
            domain=string(piclientObj.PIServer.CurrentUserName);
            if~isempty(domain)
                domain=split(domain,"\");
            end
            piclientObj.Domain=domain(1);
        end
    end


    methods(Access=public)

        function tagNames=tags(piclientObj,varargin)
            icomm.pi.internal.checkLicense();

            try

                narginchk(1,3);
            catch
                throwAsCaller(MException(message('icomm_osisoftpi:messages:InputArgsCount',piclientObj.TagsExample)));
            end

            parser=inputParser();
            parser.addParameter("Name","*",@(x)validateattributes(x,{'char','string'},{'scalartext'}));
            parser.parse(varargin{:});
            parsedInputs=parser.Results;

            try
                PIPoints=OSIsoft.AF.PI.PIPoint.FindPIPoints(piclientObj.PIServer,parsedInputs.Name,false);
            catch ME
                if contains(ME.message,"Value cannot be null")
                    error(message('icomm_osisoftpi:messages:TagBlank'));
                else
                    throwAsCaller(ME);
                end
            end
            enumerable=NET.explicitCast(PIPoints,'System.Collections.IEnumerable');
            enumerator=enumerable.GetEnumerator();
            enumerator=NET.explicitCast(enumerator,'System.Collections.IEnumerator');

            tagNames=string.empty(1,0);
            while enumerator.MoveNext()
                tagNames(end+1)=enumerator.Current.Name;%#ok<AGROW>
            end

            tagNames=tagNames';
            tagNames=array2table(tagNames,VariableNames="Tags");
        end


        function valuesTT=read(piclientObj,tagNames,varargin)
            icomm.pi.internal.checkLicense();

            try

                narginchk(2,8);
            catch
                error(message('icomm_osisoftpi:messages:InputArgsCount',piclientObj.ReadExample));
            end

            defaultDT=datetime;
            defaultDuration=duration(days(-1));
            tagNames=convertCharsToStrings(tagNames);

            p=inputParser();
            p.CaseSensitive=false;
            p.PartialMatching=true;
            p.addRequired("Tags",@(x)validateattributes(x,{'string'},{}));
            p.addParameter("Earliest",false,@(x)validateattributes(x,{'logical'},{}));
            p.addParameter("DateRange",[defaultDT,defaultDT],@(x)validateattributes(x,{'datetime'},{'row','size',[1,2]}));
            p.addParameter("Interval",defaultDuration,@(x)validateattributes(x,{'duration'},{'scalar'}));
            p.parse(tagNames,varargin{:});
            parsedInputs=p.Results;

            usingDefaults=convertCharsToStrings(p.UsingDefaults);
            if~(numel(parsedInputs.Tags)==numel(unique(parsedInputs.Tags)))
                error(message('icomm_osisoftpi:messages:TagsNotUnique'))
            end

            numTags=numel(parsedInputs.Tags);
            earliest=parsedInputs.Earliest;
            dateRange=parsedInputs.DateRange;
            startDate=dateRange(1);
            endDate=dateRange(2);

            if any("DateRange"==usingDefaults)
                latest=true;
            else
                latest=false;
            end
            interval=parsedInputs.Interval;

            if earliest||latest
                startDate=datetime([1971,1,1,0,0,0]);
            end

            if~earliest
                if startDate>endDate
                    error(message('icomm_osisoftpi:messages:InvalidDateRange'))
                end
            end


            if isempty(startDate.TimeZone)

                startDate=datetime(startDate,"TimeZone","local");
                startDate.TimeZone=icomm.pi.internal.defaultTimeZone();
            end
            if isempty(endDate.TimeZone)

                endDate=datetime(endDate,"TimeZone","local");
                endDate.TimeZone=icomm.pi.internal.defaultTimeZone();
            end


            emptyTimes=datetime.empty(0,1);
            emptyTimes.TimeZone=icomm.pi.internal.defaultTimeZone();
            valuesTT=timetable('RowTimes',emptyTimes);

            for tagIndex=1:numTags

                try
                    [tag,tagName,safeTagName]=processTagName(piclientObj,parsedInputs.Tags(tagIndex));
                catch ME
                    if contains(ME.message,"PI Point not found")
                        error(message('icomm_osisoftpi:messages:TagNotFound',parsedInputs.Tags(tagIndex)));
                    else
                        throwAsCaller(ME);
                    end
                end
                afTimeRange=OSIsoft.AF.Time.AFTimeRange(icomm.pi.internal.datetime2aftime(startDate),icomm.pi.internal.datetime2aftime(endDate));
                boundary=OSIsoft.AF.Data.AFBoundaryType.Inside;

                if earliest
                    readValues=tag.RecordedValues(afTimeRange,boundary,'',true,1);

                elseif latest
                    readValues=tag.RecordedValues(afTimeRange,boundary,'',true);

                elseif interval>=0
                    afTimeSpan=icomm.pi.internal.duration2aftimespan(interval);
                    readValues=tag.InterpolatedValues(afTimeRange,afTimeSpan,'',true);

                else
                    readValues=tag.RecordedValues(afTimeRange,boundary,'',true);
                end

                readValues=piclientObj.createTable(readValues,tagName,safeTagName);

                if latest
                    readValues=tail(readValues,1);
                end
                valuesTT=[valuesTT;readValues];

                valuesTT=sortrows(valuesTT);
            end
            valuesTT.Time.Format=icomm.pi.internal.Locale.DatetimeFormat;
        end


        function viewer(piclientObj)
            icomm.pi.internal.checkLicense();
            defaultPosition=[0.2,0.2,0.6,0.6];
            parentForPosition=figure('Visible','off','Units','normalized','Position',defaultPosition);
            deleteParentForPosition=onCleanup(@()delete(parentForPosition));
            parentForPosition.Units='pixels';
            parent=uifigure('Position',parentForPosition.Position);
            icomm.pi.app.web.PIViewer('Parent',parent,'PIClient',piclientObj);
        end
    end


    methods(Access=public,Hidden=true)

        function tagNames=findTags(piclientObj,tagName)

            try

                narginchk(2,2);
            catch
                throwAsCaller(MException(message('icomm_osisoftpi:messages:InputArgsCount',piclientObj.FindTagsExample)));
            end

            validateattributes(tagName,{'char','string'},{'scalartext'});
            tagName=convertStringsToChars(tagName);

            try
                PIPoints=OSIsoft.AF.PI.PIPoint.FindPIPoints(piclientObj.PIServer,tagName,false);
            catch ME
                if contains(ME.message,"Value cannot be null")
                    error(message('icomm_osisoftpi:messages:TagBlank'));
                else
                    throwAsCaller(ME);
                end
            end
            enumerable=NET.explicitCast(PIPoints,'System.Collections.IEnumerable');
            enumerator=enumerable.GetEnumerator();
            enumerator=NET.explicitCast(enumerator,'System.Collections.IEnumerator');

            tagNames=string.empty(1,0);
            while enumerator.MoveNext()
                tagNames(end+1)=enumerator.Current.Name;%#ok<AGROW>
            end
        end


        function valuesTT=getRecordedValues(piclientObj,tagNames,varargin)

            try

                narginchk(2,6);
            catch

                throwAsCaller(MException(message('icomm_osisoftpi:messages:InputArgsCount',piclientObj.RecordedValuesExample)));
            end

            tagNames=convertCharsToStrings(tagNames);

            p=inputParser();
            p.addRequired("Tags",@(x)validateattributes(x,{'string'},{}));
            p.addParameter("From",datetime("now")-days(1),@(x)validateattributes(x,{'datetime'},{'scalar'}));
            p.addParameter("To",datetime("now"),@(x)validateattributes(x,{'datetime'},{'scalar'}));
            p.parse(tagNames,varargin{:});
            parsedInputs=p.Results;

            startDate=parsedInputs.From;
            endDate=parsedInputs.To;
            if~(numel(parsedInputs.Tags)==numel(unique(parsedInputs.Tags)))
                error(message('icomm_osisoftpi:messages:TagsNotUnique'))
            end
            numTags=numel(parsedInputs.Tags);

            if isempty(startDate.TimeZone)

                startDate=datetime(startDate,"TimeZone","local");
                startDate.TimeZone=icomm.pi.internal.defaultTimeZone();
            end
            if isempty(endDate.TimeZone)

                endDate=datetime(endDate,"TimeZone","local");
                endDate.TimeZone=icomm.pi.internal.defaultTimeZone();
            end

            emptyTimes=datetime.empty(0,1);
            emptyTimes.TimeZone=icomm.pi.internal.defaultTimeZone();
            valuesTT=timetable('RowTimes',emptyTimes);

            for tagIndex=1:numTags

                try
                    [tag,tagName,safeTagName]=processTagName(piclientObj,parsedInputs.Tags(tagIndex));
                catch ME
                    if contains(ME.message,"PI Point not found")
                        error(message('icomm_osisoftpi:messages:TagNotFound',parsedInputs.Tags(tagIndex)));
                    else
                        throwAsCaller(ME);
                    end
                end
                afTimeRange=OSIsoft.AF.Time.AFTimeRange(icomm.pi.internal.datetime2aftime(startDate),icomm.pi.internal.datetime2aftime(endDate));
                boundary=OSIsoft.AF.Data.AFBoundaryType.Inside;

                values=tag.RecordedValues(afTimeRange,boundary,'',true);
                [values,times,statuses]=icomm.pi.internal.afvalues2matlab(values);

                statuses=categorical(string(statuses),string(enumeration('icomm.pi.internal.AFValueStatus')),'Protected',true);
                values=timetable(values(:),statuses(:),'RowTimes',times,'VariableNames',{char(safeTagName),sprintf('%s_Status',safeTagName)});
                values.Properties.VariableDescriptions={char(tagName),sprintf('%s_Status',tagName)};
                values.Properties.VariableContinuity={'continuous','event'};
                synchronizedTimes=union(valuesTT.Time,values.Time);
                valuesTT=synchronize(valuesTT,values,synchronizedTimes,'fillwithmissing');
            end
            valuesTT.Time.Format=icomm.pi.internal.Locale.DatetimeFormat;
        end


        function valuesTT=getInterpolatedValues(piclientObj,tagNames,varargin)

            try
                narginchk(2,8);
            catch

                throwAsCaller(MException(message('icomm_osisoftpi:messages:InputArgsCount',piclientObj.InterpolatedValuesExample)));
            end
            tagNames=convertCharsToStrings(tagNames);

            p=inputParser();
            p.addRequired("Tags",@(x)validateattributes(x,{'string'},{}));
            p.addParameter("From",datetime("now")-days(1),@(x)validateattributes(x,{'datetime'},{'scalar'}));
            p.addParameter("To",datetime("now"),@(x)validateattributes(x,{'datetime'},{'scalar'}));
            p.addParameter("Every",minutes(5),@(x)validateattributes(x,{'duration','calendarDuration'},{'scalar'}));
            p.parse(tagNames,varargin{:});
            parsedInputs=p.Results;

            startDate=parsedInputs.From;
            endDate=parsedInputs.To;
            interval=parsedInputs.Every;
            if~(numel(parsedInputs.Tags)==numel(unique(parsedInputs.Tags)))
                error(message('icomm_osisoftpi:messages:TagsNotUnique'))
            end
            numTags=numel(parsedInputs.Tags);

            if isempty(startDate.TimeZone)

                startDate=datetime(startDate,"TimeZone","local");
                startDate.TimeZone=icomm.pi.internal.defaultTimeZone();
            end
            if isempty(endDate.TimeZone)

                endDate=datetime(endDate,"TimeZone","local");
                endDate.TimeZone=icomm.pi.internal.defaultTimeZone();
            end

            emptyTimes=datetime.empty(0,1);
            emptyTimes.TimeZone=icomm.pi.internal.defaultTimeZone();
            valuesTT=timetable('RowTimes',emptyTimes);

            for tagIndex=1:numTags

                try
                    [tag,tagName,safeTagName]=processTagName(piclientObj,parsedInputs.Tags(tagIndex));
                catch ME
                    if contains(ME.message,"PI Point not found")
                        error(message('icomm_osisoftpi:messages:TagNotFound',parsedInputs.Tags(tagIndex)));
                    else
                        throwAsCaller(ME);
                    end
                end

                afTimeRange=OSIsoft.AF.Time.AFTimeRange(icomm.pi.internal.datetime2aftime(startDate),icomm.pi.internal.datetime2aftime(endDate));
                boundary=OSIsoft.AF.Data.AFBoundaryType.Inside;

                afTimeSpan=icomm.pi.internal.duration2aftimespan(interval);
                values=tag.InterpolatedValues(afTimeRange,afTimeSpan,'',true);

                [values,times,statuses]=icomm.pi.internal.afvalues2matlab(values);

                statuses=categorical(string(statuses),string(enumeration('icomm.pi.internal.AFValueStatus')),'Protected',true);
                values=timetable(values(:),statuses(:),'RowTimes',times,'VariableNames',{char(safeTagName),sprintf('%s_Status',safeTagName)});
                values.Properties.VariableDescriptions={char(tagName),sprintf('%s_Status',tagName)};
                values.Properties.VariableContinuity={'continuous','event'};

                synchronizedTimes=union(valuesTT.Time,values.Time);
                valuesTT=synchronize(valuesTT,values,synchronizedTimes,'fillwithmissing');
            end

            valuesTT.Time.Format=icomm.pi.internal.Locale.DatetimeFormat;
        end


        function valuesTT=getStartTimeOfTags(piclientObj,tags)

            icomm.pi.internal.checkLicense();

            try

                narginchk(2,2);
            catch

                throwAsCaller(MException(message('icomm_osisoftpi:messages:InputArgsCount',piclientObj.StartTimeOfTagsExample)));
            end

            tags=convertCharsToStrings(tags);
            validateattributes(tags,{'string'},{});

            valuesTT=datetime(zeros(size(tags)),'ConvertFrom','posixtime','TimeZone',icomm.pi.internal.defaultTimeZone());
            valuesTT=datetime(valuesTT,'Format','d-MMMM-y HH:mm:ss');

            for tagIndex=1:numel(tags)
                baseTime=icomm.pi.internal.datetime2aftime(datetime(now,'ConvertFrom','posixtime','TimeZone',icomm.pi.internal.defaultTimeZone()));
                try
                    tag=OSIsoft.AF.PI.PIPoint.FindPIPoint(piclientObj.PIServer,tags(tagIndex));
                catch ME
                    if contains(ME.message,"PI Point not found")
                        error(message('icomm_osisoftpi:messages:TagNotFound',tags(tagIndex)));
                    else
                        throwAsCaller(ME);
                    end
                end
                value=tag.RecordedValue(baseTime,OSIsoft.AF.Data.AFRetrievalMode.After);
                [~,time]=icomm.pi.internal.afvalues2matlab(value);
                valuesTT(tagIndex)=time;
            end
        end
    end

    methods(Access=private)

        function[tag,tagName,safeTagName]=processTagName(obj,tagName)



            safeTagName=matlab.lang.makeValidName(tagName);


            if(strlength(safeTagName)>56)
                safeTagName=convertStringsToChars(safeTagName);
                safeTagName=safeTagName(1:end-7);
                safeTagName=convertCharsToStrings(safeTagName);
            end



            try
                tag=OSIsoft.AF.PI.PIPoint.FindPIPoint(obj.PIServer,tagName);
            catch ME
                throwAsCaller(ME);
            end
        end

        function values=createTable(~,values,tagName,safeTagName)



            [values,times,statuses]=icomm.pi.internal.afvalues2matlab(values);

            statuses=categorical(string(statuses),string(enumeration('icomm.pi.internal.AFValueStatus')),'Protected',true);

            count=numel(values);
            tagarray=strings;
            for index=1:count
                tagarray(index)=tagName;
            end

            if count>0
                values=timetable(tagarray(:),values(:),statuses(:),'RowTimes',times,'VariableNames',{'Tag','Value','Status'});
                values.Properties.VariableDescriptions={'Tag Name','Tag Value','Value Status'};
                values.Properties.VariableContinuity={'event','continuous','event'};
            else
                values=timetable();
            end
        end
    end

    methods(Static,Access=private)

        function addAssembly()




            netEnvironment=dotnetenv;

            if(netEnvironment.Runtime=="core")
                error(message('icomm_osisoftpi:messages:CoreNotSupported'));
            end


            try
                NET.addAssembly('OSIsoft.AFSDK');
            catch
                error(message('icomm_osisoftpi:messages:AFSDKNotFound'));
            end


            try
                NET.addAssembly(fullfile(fileparts(icomm.pi.internal.piclientroot),'+internal','lib','NETUtilities.dll'));
            catch
                error(message('icomm_osisoftpi:messages:LibraryNotFound','NETUtilities.dll'));
            end
        end
    end

    methods(Static,Hidden=true)


        function piclientObj=loadobj(s)
            warnState=warning('backtrace','off');
            warning(message('icomm_osisoftpi:messages:UnableToLoad'));
            warning(warnState);
        end
    end
end