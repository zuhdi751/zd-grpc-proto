# Replace this with your own github.com/<username>/<repository>
GO_MODULE := github.com/zuhdi751/zd-grpc-proto

.PHONY: clean
clean:
ifeq ($(OS), Windows_NT)
	if exist "protogen" rd /s /q protogen
	mkdir protogen\go
else
	rm -fR ./protogen 
	mkdir -p ./protogen/go
endif


.PHONY: protoc-go
protoc-go3:
	protoc --go_opt=module=${GO_MODULE} --go_out=. \
	--go-grpc_opt=module=${GO_MODULE} --go-grpc_out=. \
	./proto/hello/*.proto ./proto/payment/*.proto ./proto/transaction/*.proto \
	./proto/bank/*.proto ./proto/bank/type/*.proto \


protoc-go2:
	protoc \
	--proto_path=. --proto_path=./proto/bank --proto_path=./proto/google/type \
	--go_opt=module=${GO_MODULE} --go_out=. \
	--go-grpc_opt=module=${GO_MODULE} --go-grpc_out=. \
	--include_imports --descriptor_set_out \
	--include_source_info --descriptor_set_out \
	./proto/hello/hello.proto ./proto/payment/payment.proto ./proto/transaction/cart.proto \
	./proto/bank/service.proto ./proto/bank/type/account.proto

protoc-go:
	protoc \
	--proto_path=. --proto_path=./proto/bank --proto_path=./proto/google/type \
	--go_opt=module=${GO_MODULE} --go_out=. \
	--go-grpc_opt=module=${GO_MODULE} --go-grpc_out=. \
	./proto/hello/hello.proto ./proto/payment/payment.proto ./proto/transaction/cart.proto \
	./proto/bank/service.proto ./proto/bank/type/account.proto \
	./proto/bank/type/exchange.proto ./proto/bank/type/transaction.proto

.PHONY: build
build: clean protoc-go


.PHONY: pipeline-init
pipeline-init:
	sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest


.PHONY: pipeline-build
pipeline-build: pipeline-init build

## gateway ##

.PHONY: clean-gateway
clean-gateway:
ifeq ($(OS), Windows_NT)
	if exist "protogen\gateway" rd /s /q protogen\gateway
	mkdir protogen\gateway\go
	mkdir protogen\gateway\openapiv2
else
	rm -fR ./protogen/gateway 
	mkdir -p ./protogen/gateway/go
	mkdir -p ./protogen/gateway/openapiv2
endif


.PHONY: protoc-go-gateway
protoc-go-gateway:
	protoc -I . \
	--grpc-gateway_out ./protogen/gateway/go \
	--grpc-gateway_opt logtostderr=true \
	--grpc-gateway_opt paths=source_relative \
	--grpc-gateway_opt standalone=true \
	--grpc-gateway_opt generate_unbound_methods=true \
	./proto/hello/*.proto \
	

.PHONY: protoc-openapiv2-gateway
protoc-openapiv2-gateway:
	protoc -I . --openapiv2_out ./protogen/gateway/openapiv2 \
	--openapiv2_opt logtostderr=true \
	--openapiv2_opt output_format=yaml \
	--openapiv2_opt generate_unbound_methods=true \
	--openapiv2_opt allow_merge=true \
	--openapiv2_opt merge_file_name=merged \
  ./proto/hello/*.proto \
	

.PHONY: build-gateway
build-gateway: clean-gateway protoc-go-gateway 


.PHONY: pipeline-init-gateway
pipeline-init-gateway:
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest


.PHONY: pipeline-build-gateway
pipeline-build-gateway: pipeline-init-gateway build-gateway protoc-openapiv2-gateway