SRC_DIR=src
TEST_DIR=tests

NIM_SRC_TEST_TARGET=$(TEST_DIR)/test1
NIM_BIN_TEST_TARGET=$(TEST_DIR)/bin/test1

#NIM_FLAGS=
NIM_FLAGS= -d:useSysAssert -d:useGcAssert --parallelBuild:1

test: build-test run-test

build-test: clean-tests $(NIM_BIN_TEST_TARGET)

run-test: $(NIM_BIN_TEST_TARGET)
	./$(NIM_BIN_TEST_TARGET) $(LOOPS)

build-bmtool:
	@mkdir -p $(SRC_DIR)/bin
	nim c $(NIM_FLAGS) $(SRC_DIR)/bmtool.nim

# We need to makedir here because its not automatically created and linking fails
$(NIM_BIN_TEST_TARGET): $(NIM_SRC_TEST_TARGET).nim
	@mkdir -p $(TEST_DIR)/bin
	nim c $(NIM_FLAGS) $<

# Clean operations
clean:
	@rm -rf $(SRC_DIR)/nimcache $(SRC_DIR)/bin

clean-tests: clean
	@rm -rf $(TEST_DIR)/nimcache $(TEST_DIR)/bin
