#!/usr/bin/env ruby

=begin

MRV Username generator v.0.0.1

Author: Viet Luu (MRV)

=end


require 'getoptlong'

opts = GetoptLong.new(
	['--help', '-h', GetoptLong::NO_ARGUMENT],
	['--list-formats', '-L', GetoptLong::NO_ARGUMENT],
	['--lastname', '-l', GetoptLong::REQUIRED_ARGUMENT],
	['--firstname', '-f', GetoptLong::REQUIRED_ARGUMENT],
	['--format', '-F', GetoptLong::REQUIRED_ARGUMENT]
)

fName, lName, formats = nil, nil, nil

alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
			'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
			'v', 'w', 'x', 'y', 'z']

opts.each do |opt, arg|
	case opt
	when '--help'
		puts "[!] USAGE: #{$0} -F format -f firstname -l lastname"
	when '--list-formats'
		puts "\nFormat"
		puts 'lastnamef - lastname + first initial'
		puts 'flastname - first initial + lastname'
		puts 'firstnamel - firstname + last initial'
		puts 'lfirstname - last initial + first name'
		puts "\n"
	when '--lastname'
		lName = arg
	when '--firstname'
		fName = arg
	when '--format'
		formats = arg
	end
end

if !formats.nil?
	case formats
	when 'lastnamef'
		if !lName.nil?
			alphabet.each do |x|
				File.open(lName, "r").each do |lastName|
					puts "#{lastName.gsub("\n", '')}#{x}"
				end	
			end
		else
			puts '--lastname requires an argument'
		end
	when 'flastname'
		if !lName.nil?
			alphabet.each do |x|
				File.open(lName, "r").each do |lastName|
					puts "#{x}#{lastName.gsub("\n", '')}"
				end	
			end
		else
			puts '--lastname requires an argument'
		end
	when 'firstnamel'
		if !fName.nil?
			alphabet.each do |x|
				File.open(fName, "r").each do |firstName|
					puts "#{firstName.gsub("\n", '')}#{x}"
				end	
			end
		else
			puts '--firstname requires an argument'
		end
	when 'lfirstname'
		if !fName.nil?
			alphabet.each do |x|
				File.open(fName, "r").each do |firstName|
					puts "#{x}#{firstName.gsub("\n", '')}"
				end	
			end
		else
			puts '--firstname requires an argument'
		end
	end
end
