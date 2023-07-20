function saveMAResultDetails(obj,ResultDetailsCellArray)
    obj.deleteData('resultdetails');
    obj.bulkSaveData('resultdetails',ResultDetailsCellArray);
end