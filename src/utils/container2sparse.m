function res = container2sparse(cont, max_size)
% converts a int : int container to a sparse array
res = zeros(1, max_size);
keys = cont.keys;
keys = [keys{:}];
vals = cont.values;
vals = [vals{:}];
res(keys) = vals;
res = sparse(res);
