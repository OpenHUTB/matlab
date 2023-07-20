function utError(id,varargin)






    full_id=Simulink.SimulationData.errorID(id);


    mObj=message(full_id,varargin{:});
    msg=mObj.getString;


    exception=MException(full_id,'%s',msg);
    throwAsCaller(exception);

end
