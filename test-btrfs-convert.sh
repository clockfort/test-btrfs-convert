#!/bin/bash

destination_dir="/tmp/test";
testing_version_of_btrfs_convert="/home/clockfort/code/btrfs-progs/btrfs-convert"
image_file="/tmp/test.fs"

populate_with_test_files ()
{
	for i in {1..7}
	do
		size=$((2**$i));
		dd if=/dev/urandom of=${destination_dir}/file${i} bs=1M count=${size};
	done
}

umount $destination_dir
rm -r $destination_dir
mkdir $destination_dir
dd if=/dev/zero of=${image_file} bs=1M count=2K
yes | mkfs.ext4 $image_file
mount $image_file $destination_dir
echo "Populating with test files..."
populate_with_test_files;
echo "Generating hashes..."
md5sum ${destination_dir}/* > ext4_sums


umount $destination_dir
#btrfs-convert $image_file
echo "Starting btrfs conversion."
${testing_version_of_btrfs_convert} -l 4K $image_file
mount $image_file $destination_dir
md5sum ${destination_dir}/* > btrfs_sums

if diff ext4_sums btrfs_sums ; then
	echo "SUCCESS. Test data matches."
else
	echo "!!!!!!!!! Test data failed hash check. !!!!!!!!!!"
fi


