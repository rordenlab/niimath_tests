fnm = 'Trick3D.nii';
hdr = spm_vol(fnm);
img = spm_read_vols(hdr);
hdr.fname = 'test.nii';
for z = 2:30
    for y = 2:12
        for x = 2:12
            img(x,y,z) = 5;
        end
    end
end
for z = 20:28
    for y = 24:40
        for x = 24:40
            img(x,y,z) = 0;
        end
    end
end
spm_write_vol(hdr,img);