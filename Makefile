SRC_DIR=src
TEST_DIR=tests

NIM_SRC_TEST1_TARGET=$(TEST_DIR)/test1
NIM_BIN_TEST1_TARGET=$(TEST_DIR)/bin/test1

NIM_SRC_TEST2_TARGET=$(TEST_DIR)/test2
NIM_BIN_TEST2_TARGET=$(TEST_DIR)/bin/test2

NIM_FLAGS=
#NIM_FLAGS= -d:useSysAssert -d:useGcAssert --parallelBuild:1

all: test2

test2: build-test2 run-test2

test1: build-test1 run-test1

build-test1: $(NIM_BIN_TEST1_TARGET)

run-test1: $(NIM_BIN_TEST1_TARGET)
	./$(NIM_BIN_TEST1_TARGET) $(LOOPS)

# We need to makedir here because its not automatically created and linking fails
$(NIM_BIN_TEST1_TARGET): $(NIM_SRC_TEST1_TARGET).nim
	@mkdir -p $(TEST_DIR)/bin
	nim c $(NIM_FLAGS) $<

build-test2: clean-tests $(NIM_BIN_TEST1_TARGET)

run-test2: $(NIM_BIN_TEST2_TARGET)
	./$(NIM_BIN_TEST2_TARGET) $(LOOPS)

# We need to makedir here because its not automatically created and linking fails
$(NIM_BIN_TEST2_TARGET): $(NIM_SRC_TEST2_TARGET).nim
	@mkdir -p $(TEST_DIR)/bin
	nim c $(NIM_FLAGS) $<

build-bmtool:
	@mkdir -p $(SRC_DIR)/bin
	nim c $(NIM_FLAGS) $(SRC_DIR)/bmtool.nim

# Clean operations
clean:
	@rm -rf $(SRC_DIR)/nimcache $(SRC_DIR)/bin

clean-tests: clean
	@rm -rf $(TEST_DIR)/nimcache $(TEST_DIR)/bin
