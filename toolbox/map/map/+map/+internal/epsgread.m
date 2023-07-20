function result=epsgread(tblname,code)







































    validateattributes(tblname,{'char'},{'nonempty','row'})

    if nargin<2



        [columnNames,canBeNull]=readHeader(tblname);
        columnNamesForSQL=columnNames;
        for colnum=1:length(columnNames)
            if canBeNull(colnum)



                columnNamesForSQL(colnum)="IFNULL("+columnNames(colnum)+",-999.0)";
            end
        end
        formattedSQLnames=join(columnNamesForSQL,",");



        sqlquery=char("SELECT "+formattedSQLnames+" FROM "+tblname+" WHERE auth_name='EPSG'");
        data=queryDatabase(sqlquery);


        result=cell(1+numel(data),numel(columnNames));


        result(1,:)=convertStringsToChars(columnNames);


        for k=1:numel(data)
            result(k+1,:)=data{k};
        end
    else
        if strcmp(code,'codes')


            result=readCodes(tblname);
        else


            validateattributes(code,{'double'},...
            {'real','finite','positive','integer'},'','CODE',2)
            result=readRecord(tblname,code);
        end
    end



    function codes=readCodes(tblname)





        sqlquery=char("SELECT code FROM "+tblname+" WHERE auth_name='EPSG'");
        data=queryDatabase(sqlquery);

        data=[data{:}];
        codes=double(cat(2,data{:}));
        codes=codes(:);



        function result=readRecord(tblname,code)



            [columnNames,canBeNull]=readHeader(tblname);
            columnNamesForSQL=columnNames;
            for colnum=1:length(columnNames)
                if canBeNull(colnum)



                    columnNamesForSQL(colnum)="IFNULL("+columnNames(colnum)+",-999.0)";
                end
            end
            formattedSQLnames=join(columnNamesForSQL,",");




            sqlquery=char("SELECT "+formattedSQLnames+" FROM "+tblname+" WHERE auth_name='EPSG' AND code="+code);
            data=queryDatabase(sqlquery);



            if~isempty(data)




                fieldValuePairs=[convertStringsToChars(columnNames);data{1}];
                result=struct(fieldValuePairs{:});


                for fname=string(fieldnames(result))'
                    if isequal(result.(fname),-999)
                        result.(fname)=[];
                    end
                end
            else

                result=[];
            end



            function[columnNames,canBeNull]=readHeader(tblname)





                sqlquery=char("SELECT name,""notnull"" FROM pragma_table_info('"+tblname+"')");
                data=queryDatabase(sqlquery);

                numcols=length(data);
                columnNames=strings(0,numcols);
                canBeNull=logical([0,numcols]);
                for columnnum=1:numcols
                    columninfo=data{columnnum};
                    columnNames(columnnum)=string(columninfo{1});
                    canBeNull(columnnum)=~logical(columninfo{2});
                end



                function data=queryDatabase(sqlquery)



                    mapproj=fullfile(matlabroot,'toolbox','map','mapproj');
                    filename=fullfile(mapproj,'projdata','proj.db');


                    if exist(filename,'file')~=2
                        error(message('map:fileio:fileNotFound',filename))
                    end



                    try
                        conn=matlab.depfun.internal.database.SqlDbConnector;
                        conn.connectReadOnly(filename);
                    catch
                        error(message('map:fileio:unableToOpenFile',filename))
                    end

                    try

                        conn.doSql(sqlquery)


                        data=conn.fetchRows(0);
                    catch e
                        conn.rollbackTransaction('');
                        error('map:epsgread:DatabaseError',e.message)
                    end
