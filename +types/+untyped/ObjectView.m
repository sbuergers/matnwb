classdef ObjectView < handle
    methods (Static)
        function Views = from_raw(Parent, refData)
            assert(isa(Parent, 'h5.interface.HasId'),...
                'NWB:Untyped:RegionView:FromRaw:InvalidArgument',...
                'Parent must have a retrievable Id');
            assert(isa(refData, 'uint8'),...
                'NWB:Untyped:RegionView:FromRaw:InvalidArgument',...
                'refData must be raw uint8 data');
            
            Views = types.untyped.ObjectView.empty(size(refData, 2), 0);
            for i = 1:size(refData, 2)
                data = refData(:,i);
                did = H5R.dereference(Parent.get_id(),...
                    h5.PrimitiveTypes.DatasetRegionRef.constant,...
                    data);
                Dataset = h5.Dataset(H5I.get_name(did), did);
                Views(i) = types.untyped.ObjectView(Dataset.get_name());
            end
        end
    end
    
    properties(SetAccess=private)
        path;
    end
    
    properties(Constant, Hidden)
        type = 'H5T_STD_REF_OBJ';
        reftype = 'H5R_OBJECT';
    end
    
    methods
        function obj = ObjectView(path)
            obj.path = path;
        end
        
        function v = refresh(obj, nwb)
            if ~isa(nwb, 'NwbFile')
                error('Argument `nwb` must be a valid `NwbFile`');
            end
            v = nwb.resolve(obj.path);
        end
        
        function refs = export(obj, fid, fullpath, refs)
            io.writeDataset(fid, fullpath, class(obj), obj);
        end
    end
end