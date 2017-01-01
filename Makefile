ifeq ($(shell grub-mkrescue -? &>/dev/null; echo $$?),0)
    grub-mkrescue = grub-mkrescue
else
    ifeq ($(shell grub2-mkrescue -? &>/dev/null; echo $$?),0)
        grub-mkrescue = grub2-mkrescue
    else
      $(error "grub-mkrescue is not found.")
    endif
endif

cargo: 
	xargo build --release --target x86_64-unknown-intermezzos-gnu

# cargo test fails for some reason, not sure why yet
test:
	cd console && cargo test
	cd interrupts && cargo test
	cd keyboard && cargo test
	cd pic && cargo test

iso: cargo grub.cfg
	mkdir -p target/isofiles/boot/grub
	cp grub.cfg target/isofiles/boot/grub
	cp target/x86_64-unknown-intermezzos-gnu/release/intermezzos target/isofiles/boot/
	$(grub-mkrescue) -o target/os.iso target/isofiles

run: iso
	qemu-system-x86_64 -cdrom target/os.iso
