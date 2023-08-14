function flag=isSFChart(blockH)






    flag=slprivate('is_stateflow_based_block',blockH)...
    &&strcmp('Chart',get(blockH,'SFBlockType'));

end